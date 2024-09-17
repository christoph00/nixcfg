{
  options,
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
let
  inherit (lib.internal) mkBoolOpt;
  cfg = config.profiles.internal.desktop.wayfire;

  allowedTypes =
    with types;
    oneOf [
      str
      int
      bool
      float
      (listOf (oneOf [
        float
        int
      ]))
    ];

  # Merge plugin config if defined multiple times
  mergedPlugins = builtins.attrValues (
    mapAttrs (_: foldl (a: b: recursiveUpdate b a) { }) (groupBy (x: x.plugin) cfg.settings.plugins)
  );

  # NOTE: Consumers of this module may use `lib.mkOrder 0` for plugin
  # configuration defined in multiple modules to control order of
  # `lib.types.listOf` merge (list concatenation) behaviour. Plugin
  # configuration sharing a common `plugin` attribute will be merged.
  # TODO: Allow using `lib.mkOverride` on specific settings values
  plugin = types.submodule {
    options = {
      package = mkOption {
        type = with types; nullOr package;
        default = null;
        description = ''

          Optional package containing one or more wayfire plugins not bundled
          with wayfire. If the plugin comes from a package, specify the package
          here so its provided plugins are properly loaded by Wayfire.
        '';
      };

      plugin = mkOption {
        type = types.str;
        description = ''

          Name of the plugin. Name can be obtained from the plugin documentation
          and/or the metadata XML files.
        '';
      };

      settings = mkOption {
        type = types.submodule { freeformType = types.attrsOf allowedTypes; };
        default = { };
        description = ''

          Key-value style attribute set of settings for an individual
          plugin. Valid values: int, float, bool, str, or list or floats.
          Nested attribute sets are not valid.
        '';
      };
    };
  };
in
{
  options.profiles.internal.desktop.wayfire = {
    enable = mkEnableOption "Wayfire 3D wayland compositor";

    package = mkOption {
      type = types.package;
      default = pkgs.wayfire;
      example = literalExpression "pkgs.wayfire";
      description = "Package to use";
    };

    finalPackage = mkOption {
      type = types.package;
      default = pkgs.wayfire-with-plugins.override {
        wayfire = cfg.package;
        plugins = remove null (catAttrs "package" mergedPlugins);
      };
      internal = true;
    };

    settings = mkOption {
      type = types.submodule {
        freeformType = types.attrsOf allowedTypes;

        options.plugins = mkOption {
          type = types.listOf plugin;
          default = [ ];
          example = literalExpression ''

            [
              { plugin = "move"; settings.activate = "<super> BTN_LEFT"; }
              { plugin = "place"; settings.mode = "cascade"; }
              { package = pkgs.wayfirePlugins.firedecor;
                plugin = "firedecor";
                settings = {
                  layout = "-";
                  border_size = 8;
                  active_border = [ 0.121569 0.121569 0.156863 1.000000 ];
                  inactive_border = [ 0.121569 0.121569 0.156863 1.000000 ];
                };
              }
            ]
          '';
          description = "List of plugins to enable and configure";
        };
      };
      description = ''

        Configuration options as defined in
        https://github.com/WayfireWM/wayfire/wiki/Configuration.
        Options in the #core section are implied as top-level attributes
        of the `settings` set.
      '';

    };
  };

  config =
    let

      # Convert lists to strings for generators.toINI
      listToString =
        list: concatStrings (intersperse " " (map (generators.mkValueStringDefault { }) list));

      pluginsSettings =
        let
          mkSettings =
            p:
            let
              name = p.plugin;
              content = mapAttrs (_: v: if isList v then listToString v else v) p.settings;
            in
            nameValuePair name content;
          pluginsWithSettings = filter (p: p.settings != { }) mergedPlugins;
        in
        listToAttrs (map mkSettings pluginsWithSettings);

      # Configuration not part of any plugins goes into the `core` attrset,
      # and each plugin will have its own attrset with corresponding settings
      settings = pluginsSettings // {
        core = overrideExisting cfg.settings {
          # `input` and `output` are `core` plugins and are loaded by default,
          # it is unnecessary to put them in the plugins list
          plugins =
            let
              filterFn =
                p:
                let
                  notInput = p.plugin != "input";
                  notInputDevice = (builtins.match "(input-device:.*)" p.plugin) == null;
                  notOutput = (builtins.match "(output:.*)" p.plugin) == null;
                in
                if notInput && notInputDevice && notOutput then p.plugin else "";
            in
            listToString (map filterFn mergedPlugins);
        };
      };

    in
    mkIf cfg.enable {
      home.packages = [ cfg.finalPackage ];

      xdg.configFile."wayfire.ini".text = generators.toINI { } settings;

      programs.waybar = {
        enable = true;
        package = pkgs.waybar;
        systemd = {
          enable = true;
          # target = "hyprland-session.target";
        };
        style = ./../../dotfiles/config/waybar/style.css;
        settings = {
          mainBar = {
            layer = "top";
            position = "top";
            height = 42;
            margin-left = 2;
            margin-right = 2;
            spacing = 2;

            modules-left = [
              "temperature"
              "memory"
              "cpu"
              "wlr/workspaces"
            ];
            # modules-center = ["hyprland/window"];
            modules-right = [
              "idle_inhibitor"
              "tray"
              "pulseaudio"
              "backlight"
              "battery"
              "clock"
            ];

            "custom/search" = {
              tooltip = false;
              format = " ";
              on-click = "killall fuzzel || fuzzel";
            };

            "custom/separator" = {
              format = "|";
              interval = "once";
              tooltip = false;
            };

            "wlr/workspaces" = {
              disable-scroll = true;
              disable-markup = false;
              all-outputs = false;
              on-click = "activate";
              on-scroll-up = "${pkgs.hyprland}/bin/hyprctl dispatch workspace e+1";
              on-scroll-down = "${pkgs.hyprland}/bin/hyprctl dispatch workspace e-1";
              format = " {icon} ";
              format-icons = {
                "1" = "  ";
                "2" = "  ";
                "3" = "  ";
                "4" = "  ";
                "5" = "  ";
                "6" = "  ";
                "focused" = "  ";
                "default" = "  ";
              };
              persistent_workspaces = {
                "1" = [ ];
                "2" = [ ];
                "3" = [ ];
                "4" = [ ];
                "5" = [ ];
              };
            };

            "cpu" = {
              format = "{usage}% ";
              tooltip = false;
            };

            "memory" = {
              format = "{}% ";
            };

            "temperature" = {
              # thermal-zone = 2;
              # hwmon-path = "/sys/class/hwmon/hwmon2/temp1_input";
              critical-threshold = 80;
              format-critical = "{temperatureC}°C {icon}";
              format = "{temperatureC}°C {icon}";
              format-icons = [
                "󰉬"
                ""
                "󰉪"
              ];
            };

            "wlr/taskbar" = {
              format = " {icon} {title} ";
              icon-size = 14;
              icon-theme = "Papirus-Dark";
              tooltip-format = "{app_id}";
              on-click = "activate";
              on-click-middle = "close";
            };

            "idle_inhibitor" = {
              format = "{icon}";
              format-icons = {
                "activated" = "";
                "deactivated" = "";
              };
            };

            "tray" = {
              spacing = 10;
            };

            "battery" = {
              states = {
                "good" = 95;
                "warning" = 30;
                "critical" = 15;
              };
              format = "{capacity}% {icon}";
              tooltip-format = "{timeTo}, {capacity}";
              format-alt = "{time} {icon}";
              format-icons = [
                ""
                ""
                ""
                ""
                ""
              ];
            };

            "pulseaudio" = {
              format = "{volume}% {icon} {format_source}";
              format-muted = "󰆪 {format_source}";
              format-bluetooth = "{volume}% {icon} {format_source}";
              format-bluetooth-muted = "󰆪 {icon} {format_source}";
              format-source = "{volume}% ";
              format-source-muted = "";
              ignored-sinks = [ "Easy Effects Sink" ];
              format-icons = {
                "headphone" = "";
                "hands-free" = "";
                "headset" = "";
                "phone" = "";
                "portable" = "";
                "car" = "";
                "default" = [
                  ""
                  ""
                  ""
                ];
              };
              on-click = "pavucontrol";
            };

            "backlight" = {
              format = "{percent}% {icon}";
              format-icons = [
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
              ];
            };

            "clock" = {
              format = "{:%Y-%m-%d - %I:%M}";
              tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
              # on-click = "swaync-client -t -sw";
            };
          };
        };
      };

      systemd.user.targets.wayfire-session = {
        Unit = {
          Description = "sway compositor session";
          Documentation = [ "man:systemd.special(7)" ];
          BindsTo = [ "graphical-session.target" ];
          Wants = [
            "graphical-session-pre.target"
            "xdg-desktop-autostart.target"
          ];
          After = [ "graphical-session-pre.target" ];

        };
      };

    };
}
