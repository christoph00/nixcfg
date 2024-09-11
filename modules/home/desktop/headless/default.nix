{
  options,
  config,
  lib,
  pkgs,
  namespace,
  inputs,
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
    getExe
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
      pkgs.wlr-randr
    ];

    wayland.windowManager.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraSessionCommands = ''
        # https://github.com/flameshot-org/flameshot/blob/master/docs/Sway%20and%20wlroots%20support.md#basic-steps
        export SDL_VIDEODRIVER=wayland
        export _JAVA_AWT_WM_NONREPARENTING=1
        export QT_QPA_PLATFORM=wayland
        export XDG_SESSION_DESKTOP=sway
        # TODO export XDG_SESSION_DESKTOP="''${XDG_SESSION_DESKTOP:-sway}"
      '';
      extraConfig = ''
        exec systemctl --user import-environment DISPLAY WAYLAND_DISPLAY SWAYSOCK
        exec hash dbus-update-activation-environment 2>/dev/null && \
          dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK

        # create virtual output on boot for sunshine host
        exec swaymsg create_output HEADLESS-1
        exec swaymsg output HEADLESS-1 resolution 1920x1080

        exec ${pkgs.sunshine}/bin/sunshine

      '';
      config = {
        modifier = "Mod4";
        menu = "wofi --show run";
        bars = [
          {
            command = "waybar";
          }
        ];
        output.Headless-1 = {
          mode = "1920x1080";
          pos = "0 0";
        };
        keybindings =
          let
            modifier = "Alt";
          in
          lib.mkOptionDefault {
            # Desktop Utilities
            "${modifier}+c" = "exec ${pkgs.clipman}/bin/clipman pick -t wofi";
            #"${modifier}+Shift+s" = "exec ${pkgs.sway-contrib.grimshot}/bin/grimshot copy area";
            "${modifier}+Shift+s" = "exec ${pkgs.flameshot}/bin/flameshot gui";

            # Main app shortcuts
            "${modifier}+Shift+w" = "exec ${pkgs.zen-browser}/bin/zen-browser";
            "${modifier}+Shift+v" = "exec ${pkgs.pavucontrol}/bin/pavucontrol";
          };
      };
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

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.runtimeShell} -c 'source /etc/set-environment; exec sway'";

      };

    };
  };
}
