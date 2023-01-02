{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.conf.desktop.sway;
in {
  options.conf.desktop.sway.enable = lib.mkEnableOption "Sway";
  config = lib.mkIf cfg.enable {
    programs.sway = {
      enable = true;
    };
    home-manager.users.${config.conf.users.user} = {
      wayland.windowManager.sway = with config.scheme.withHashtag; let
        modifier = "Mod4";
        lock = "${pkgs.swaylock-effects}/bin/swaylock -fF";
        makoctl = "${pkgs.mako}/bin/makoctl";
        pactl = "${pkgs.pulseaudio}/bin/pactl";
        pass-wofi = "${pkgs.pass-wofi}/bin/pass-wofi";
        chromium = "${pkgs.chromium}/bin/chromium";
        swaybg = "${pkgs.swaybg}/bin/swaybg";
        swayidle = "${pkgs.swayidle}/bin/swayidle";
        swaylock = "${pkgs.swaylock-effects}/bin/swaylock";
        systemctl = "${pkgs.systemd}/bin/systemctl";
        wofi = "${pkgs.wofi}/bin/wofi";
        launcher = "${wofi} -S drun -x 10 -y 10 -W 25% -H 60%";

        #eww = "${config.programs.eww.package}/bin/eww";

        terminal = "${pkgs.wezterm}/bin/wezterm";
        terminal-spawn = cmd: "${terminal} $SHELL -i -c ${cmd}";
      in {
        enable = true;
        systemdIntegration = true;
        xwayland = true;
        wrapperFeatures = {gtk = true;};
        extraSessionCommands = ''
          # export WLR_DRM_NO_ATOMIC=1
          export MOZ_ENABLE_WAYLAND=1
          # export QT_QPA_PLATFORM=wayland
          # export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
          # export QT_WAYLAND_FORCE_DPI=physical
          # export SDL_VIDEODRIVER=wayland
          # export GDK_BACKEND=wayland
          export _JAVA_AWT_WM_NONREPARENTING=1
          export XDG_CURRENT_DESKTOP=sway
        '';
        config = {
          output = {
            "*".bg = "${config.conf.theme.wallpaper} fill";
            "eDP-1" = {
              resolution = "1920x1080";
              position = "0,0";
              scale = "1";
            };
          };

          gaps = {
            inner = 5;
            outer = 5;
            smartGaps = true;
          };
          window.border = 2;
          window.titlebar = false;
          fonts = {
            names = ["${config.conf.fonts.monospace.name}"];
            size = 11.0;
          };

          colors = {
            background = base00;
            focused = {
              background = "#285577";
              border = base01;
              childBorder = "#285577";
              indicator = "#2e9ef4";
              text = "#ffffff";
            };
            unfocused = {
              background = "#222222";
              border = base04;
              childBorder = "#222222";
              indicator = "#292d2e";
              text = "#888888";
            };
          };

          bars = [];

          input = {
            "*" = {
              tap = "enabled";
            };
          };

          floating.modifier = "Mod4";
          keybindings = {
            "${modifier}+Space" = "exec ${launcher}";
            "${modifier}+Return" = "exec ${terminal}";
            "${modifier}+l" = "exec ${lock}";

            "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl s +10%";
            "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl s 10%-";

            "${modifier}+s" = "layout stacking";
            "${modifier}+w" = "layout tabbed";
            "${modifier}+e" = "layout toggle split";

            "${modifier}+c" = "kill";

            "${modifier}+1" = "workspace number 1";
            "${modifier}+2" = "workspace number 2";
            "${modifier}+3" = "workspace number 3";
            "${modifier}+4" = "workspace number 4";
            "${modifier}+5" = "workspace number 5";
            "${modifier}+6" = "workspace number 6";
            "${modifier}+7" = "workspace number 7";
            "${modifier}+8" = "workspace number 8";
            "${modifier}+9" = "workspace number 9";

            "${modifier}+Shift+1" = "move container to workspace number 1";
            "${modifier}+Shift+2" = "move container to workspace number 2";
            "${modifier}+Shift+3" = "move container to workspace number 3";
            "${modifier}+Shift+4" = "move container to workspace number 4";
            "${modifier}+Shift+5" = "move container to workspace number 5";
            "${modifier}+Shift+6" = "move container to workspace number 6";
            "${modifier}+Shift+7" = "move container to workspace number 7";
            "${modifier}+Shift+8" = "move container to workspace number 8";
            "${modifier}+Shift+9" = "move container to workspace number 9";
          };
        };
      };
    };
  };
}
