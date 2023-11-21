{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.desktop.idle;
in {
  options.chr.desktop.idle = with types; {
    enable = mkBoolOpt' config.chr.desktop.enable;
  };

  config.chr.home.extraOptions = lib.mkIf cfg.enable {
     home.packages = [pkgs.gtklock];

  xdg.configFile."gtklock/style.css".text = ''
    window {
      background: rgba(0, 0, 0, .5);
      font-family: Lexend;
    }

    grid > label {
      color: transparent;
      margin: -20rem;
    }

    button {
      all: unset;
      color: transparent;
      margin: -20rem;
    }

    #clock-label {
      font-size: 6rem;
      margin-bottom: 4rem;
      text-shadow: 0px 2px 10px rgba(0, 0, 0, .1);
    }

    entry {
      border-radius: 16px;
      margin: 6rem;
      box-shadow: 0 1px 3px rgba(0, 0, 0, .1);
    }
    '';

    services.swayidle = {
      enable = true;
      extraArgs = ["-d"];
      systemdTarget = "hyprland-session.target";
      timeouts = [
        {
          timeout = 2400;
          command = "hyprctl dispatch dpms off";
          resumeCommand = "hyprctl dispatch dpms on";
        }
        {
          timeout = 3600;
          command = "systemctl hybrid-sleep";
        }
      ];
      events = [
        {
          event = "before-sleep";
          command = "${pkgs.gtklock}/bin/gtklock -g Tokyonight-Dark-B";
        }
        # { event = "after-resume"; command = "hyprctl dispatch dpms on"; }
      ];
    };
  };
}
