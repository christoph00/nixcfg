{
  options,
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib)
    types
    listOf
    mkIf
    mkMerge
    mkDefault
    mkOption
    optional
    asserts
    ;
  inherit (lib.internal) mkBoolOpt;
  cfg = config.profiles.internal.desktop.headless;

in
{
  options.profiles.internal.desktop.headless = with types; {
    enable = mkBoolOpt false "Enable Headless Desktop";
    autorun = mkBoolOpt true "Auto Start Service";
    vnc = {
      addr = mkOption {
        type = types.str;
        default = "0.0.0.0";
        description = ''
          Which address should wayvnc listen to.
        '';
      };
      maxFps = mkOption {
        type = types.int;
        default = 30;
        description = ''
          Set the rate limit.
        '';
      };
      port = mkOption {
        type = types.int;
        default = 5900;
        description = ''
          Set the port to listen on.
        '';
      };
    };
  };

  config = mkIf cfg.enable {

    home.packages = [
      pkgs.wayvnc
      pkgs.wlr-randr
    ];

    xdg.configFile."wayvnc/config".text = ''
      port=${toString cfg.vnc.port}
    '';

    profiles.internal.desktop.wayfire.settings = {
      plugins = [
        {
          plugin = "output:HEADLESS-1";
          settings.mode = "1920x1080@60000";
        }
        {
          plugin = "output:HDMI-A-1";
          settings.mode = "off";
        }
        {
          plugin = "output:DP-1";
          settings.mode = "off";
        }
      ];
    };

    systemd.user.services.wayvnc = {
      Unit = {
        Description = "a VNC server for wlroots based Wayland compositors";
        After = [ "graphical-session-pre.target" ];
        # PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Restart = "on-failure";
        ExecStart = ''
          ${pkgs.wayvnc}/bin/wayvnc -g \
                    -f ${
                      assert asserts.assertMsg (cfg.vnc.maxFps > 0) "Rate limit for WayVNC must be a positive integer!";
                      toString cfg.vnc.maxFps
                    } \
                    ${cfg.vnc.addr}
        '';
      };

      # Install = {
      #   WantedBy = [ "graphical-session.target" ];
      # };
    };

    systemd.user.services.headless-desktop = {
      Unit = {
        Description = "Headless Desktop";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session-pre.target" ];

      };
      Install.WantedBy = [
        (lib.mkIf cfg.autorun "default.target")
      ];

      #environment.PATH = lib.mkForce null;
      Service = {
        Type = "simple";
        #ExecStartPre =  "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP; systemctl --user import-environment";
        ExecStart = "${pkgs.runtimeShell} -c 'source /etc/set-environment; exec ${config.profiles.internal.desktop.wayfire.finalPackage}/bin/wayfire'";

      };

    };
  };
}
