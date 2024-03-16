{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.desktop.wayfire;
  allowedTypes = with types;
    oneOf [str int bool float (listOf (oneOf [float int]))];
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
        type = types.submodule {freeformType = types.attrsOf allowedTypes;};
        default = {};
        description = ''
          Key-value style attribute set of settings for an individual
          plugin. Valid values: int, float, bool, str, or list or floats.
          Nested attribute sets are not valid.
        '';
      };
    };
  };
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
  pactl = "${pkgs.pulseaudio}/bin/pactl";
in {
  imports = [./settings.nix ./shell.nix];
  options.chr.desktop.wayfire = with types; {
    enable = mkBoolOpt false "Whether or not enable Wayfire Desktop.";
    scale = lib.mkOption {
      type = lib.types.str;
      default = "1";
    };
    layout = lib.mkOption {
      type = lib.types.str;
      default = "de";
    };
    shell = {
      enable = mkBoolOpt' config.chr.desktop.wayfire.enable;
      dock = mkBoolOpt' config.chr.desktop.wayfire.shell.enable;
      background = mkBoolOpt' config.chr.desktop.wayfire.shell.enable;
      panel = mkBoolOpt' config.chr.desktop.wayfire.shell.enable;
      settings = mkOption {
        type = with types; attrsOf (attrsOf (oneOf [str bool int]));
      };
    };

    settings = mkOption {
      type = types.submodule {
        freeformType = types.attrsOf allowedTypes;

        options.plugins = mkOption {
          type = types.listOf plugin;
          default = [];
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

  config = let
    # Merge plugin config if defined multiple times
    mergedPlugins = builtins.attrValues (
      mapAttrs
      (_: foldl (a: b: recursiveUpdate b a) {})
      (groupBy (x: x.plugin) cfg.settings.plugins)
    );

    # Convert lists to strings for generators.toINI
    listToString = list:
      concatStrings (intersperse " " (map (generators.mkValueStringDefault {}) list));

    pluginsSettings = let
      mkSettings = p: let
        name = p.plugin;
        content = mapAttrs (_: v:
          if isList v
          then listToString v
          else v)
        p.settings;
      in
        nameValuePair name content;
      pluginsWithSettings = filter (p: p.settings != {}) mergedPlugins;
    in
      listToAttrs (map mkSettings pluginsWithSettings);

    # Configuration not part of any plugins goes into the `core` attrset,
    # and each plugin will have its own attrset with corresponding settings
    settings =
      pluginsSettings
      // {
        core = overrideExisting cfg.settings {
          # `input` and `output` are `core` plugins and are loaded by default,
          # it is unnecessary to put them in the plugins list
          plugins = let
            filterFn = p: let
              notInput = p.plugin != "input";
              notInputDevice = (builtins.match "(input-device:.*)" p.plugin) == null;
              notOutput = (builtins.match "(output:.*)" p.plugin) == null;
            in
              if notInput && notInputDevice && notOutput
              then p.plugin
              else "";
          in
            listToString (map filterFn mergedPlugins);
        };
      };

    finalPackage = pkgs.wayfire-with-plugins.override {
      wayfire = pkgs.wayfire;
      plugins = remove null (catAttrs "package" mergedPlugins);
    };
  in
    mkIf cfg.enable {
      chr.desktop = {
        anyrun.enable = true;
        wayfire.shell.dock = true;
        wayfire.shell.panel = false;
        ags.enable = true;
      };

      programs.wayfire = {
        enable = true;
        package = finalPackage;
      };
      xdg.portal = {
        enable = true;
        extraPortals = [pkgs.xdg-desktop-portal-gtk];
      };

      services.greetd = {
        enable = true;
        settings = {
          # default_session.command = ''
          #   ${pkgs.greetd.tuigreet}/bin/tuigreet --remember --user-menu --asterisks --time --greeting "Welcome to NixOS" --cmd ${plasma}/bin/plasma'';
          initial_session = {
            command = "${finalPackage}/bin/wayfire";
            user = config.chr.user.name;
          };
        };
      };
      programs.regreet.enable = true;
      environment.persistence."${config.chr.system.persist.stateDir}".directories = lib.mkIf config.chr.system.persist.enable ["/var/cache/regreet"];

      security = {
        polkit.enable = true;
      };

      environment.systemPackages = with pkgs.gnome; [
        pkgs.loupe
        adwaita-icon-theme
        nautilus
        baobab
        gnome-calendar
        gnome-boxes
        gnome-system-monitor
        gnome-control-center
        gnome-weather
        gnome-calculator
        gnome-clocks
        finalPackage
      ];

      systemd = {
        user.services.polkit-gnome-authentication-agent-1 = {
          description = "polkit-gnome-authentication-agent-1";
          wantedBy = ["graphical-session.target"];
          wants = ["graphical-session.target"];
          after = ["graphical-session.target"];
          serviceConfig = {
            Type = "simple";
            ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
            Restart = "on-failure";
            RestartSec = 1;
            TimeoutStopSec = 10;
          };
        };
      };

      environment = {
        variables = {
          NIXOS_OZONE_WL = "1";
          _JAVA_AWT_WM_NONEREPARENTING = "1";
          GDK_BACKEND = "wayland,x11";
          ANKI_WAYLAND = "1";
          MOZ_ENABLE_WAYLAND = "1";
          XDG_SESSION_TYPE = "wayland";
          SDL_VIDEODRIVER = "wayland";
          CLUTTER_BACKEND = "wayland";
          WLR_DRM_NO_ATOMIC = "1";
        };
      };

      chr.home.extraOptions = {
        home.sessionVariables = {
          # Programs may use this for WM/DE specific behavior.
          XDG_CURRENT_DESKTOP = "sway";

          # Programs may use this for Wayland detection.
          XDG_SESSION_TYPE = "wayland";
        };

        xdg.configFile."wayfire.ini".text = generators.toINI {} settings;
        xdg.configFile."wf-shell.ini".text = generators.toINI {} cfg.shell.settings;
      };

      services = {
        gvfs.enable = true;
        devmon.enable = true;
        udisks2.enable = true;
        upower.enable = true;
        accounts-daemon.enable = true;
        gnome = {
          evolution-data-server.enable = true;
          glib-networking.enable = true;
          gnome-keyring.enable = true;
          gnome-online-accounts.enable = true;
        };
      };
    };
}
