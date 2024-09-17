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

      programs.ironbar = {
        enable = true;
        systemd = false; # not support niri
        config = {
          anchor_to_edges = true;
          position = "bottom";
          icon_theme = "Paper";
          start = [
            {
              type = "launcher";
              favorites = [
                 "zen-browser"
              ];
              show_names = false;
              show_icons = true;
            }
            {
              type = "focused";
            }
          ];
          end = [
 
            {
              type = "sys_info";
              format = [
                # " {cpu_percent}% | {temp_c:k10temp_Tccd1}°C"
                " {memory_used}/{memory_total} GB ({memory_percent}%)"
                # "| {swap_used} / {swap_total} GB ({swap_percent}%)"
                # "󰋊 {disk_used:/nix}/{disk_total:/nix} GB ({disk_percent:/nix}%)"
                "󰓢 {net_up:enp3s0}/{net_down:enp3s0} Mbps"
                "󰖡 {load_average:5}"
                # "󰥔 {uptime}"
              ];
              interval = {
                memory = 30;
                cpu = 1;
                temps = 5;
                disks = 300;
                networks = 3;
              };
            }
            {
              type = "volume";
              format = "{icon} {percentage}%";
              max_volume = 100;
              icons = {
                volume_high = "󰕾";
                volume_medium = "󰖀";
                volume_low = "󰕿";
                muted = "󰝟";
              };
            }
            {
              type = "clipboard";
              max_items = 5;
              truncate = {
                mode = "end";
                length = 50;
              };
            }
            {
              "type" = "custom";
              "class" = "power-menu";
              "bar" = [
                {
                  "type" = "button";
                  "name" = "power-btn";
                  "label" = "";
                  "on_click" = "popup:toggle";
                }
              ];
              "popup" = [
                {
                  "type" = "box";
                  "orientation" = "vertical";
                  "widgets" = [
                    {
                      "type" = "label";
                      "name" = "header";
                      "label" = "Power menu";
                    }
                    {
                      "type" = "box";
                      "widgets" = [
                        {
                          "type" = "button";
                          "class" = "power-btn";
                          "label" = "<span font-size='40pt'></span>";
                          "on_click" = "!shutdown now";
                        }
                        {
                          "type" = "button";
                          "class" = "power-btn";
                          "label" = "<span font-size='40pt'></span>";
                          "on_click" = "!reboot";
                        }
                      ];
                    }

                  ];
                }
              ];
            }
            {
              type = "clock";
              format = "%H:%M";
            }
          ];
        };
        style = "";
        package = pkgs.ironbar;
      };

      systemd.user.targets.wayfire-session = {
        Unit = {
          Description = "compositor session";
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
