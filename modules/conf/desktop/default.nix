{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.conf;
  sway-kiosk = command: "${pkgs.sway}/bin/sway --config ${pkgs.writeText "kiosk.config" ''
    output * bg #000000 solid_color
    exec dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK
    exec "${command}; ${pkgs.sway}/bin/swaymsg exit"
  ''}";
in {
  imports = [./hyprland.nix ./waybar.nix ./wofi.nix ./fonts.nix ./gtk.nix ./palette.nix ./sway.nix];

  options.conf.desktop = {
    enable = mkEnableOption "DesktopConfig";
    gaming = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.desktop.enable {
    conf.desktop.hyprland.enable = true;
    #conf.desktop.sway.enable = true;
    conf.desktop.waybar.enable = true;
    conf.desktop.wofi.enable = true;
    conf.desktop.gtk.enable = true;
    conf.theme.enable = true;
    conf.theme.palette.enable = true;
    conf.theme.wallpaper = pkgs.wallpaper.pixel-campfire01;

    conf.applications.firefox.enable = true;

    services.fwupd.enable = true;

    services.printing = {
      enable = true;
      drivers = with pkgs; [gutenprint xr6515dn];
    };

    hardware.printers.ensurePrinters = [
      {
        name = "Xerox_WorkCentre_6515DN";
        model = "xerox-workcentre-6515DN/xr6515dn.ppd";
        ppdOptions = {
          Duplex = "DuplexNoTumble";
          PageSize = "A4";
        };
        deviceUri = "ipps://xerox.lan.net.r505.de";
      }
    ];

    # Disable mitigations on desktop
    boot.kernelParams = [
      "l1tf=off"
      "mds=off"
      "mitigations=off"
      "no_stf_barrier"
      "noibpb"
      "noibrs"
      "nopti"
      "nospec_store_bypass_disable"
      "nospectre_v1"
      "nospectre_v2"
      "tsx=on"
      "tsx_async_abort=off"
    ];

    services.dbus = {
      enable = true;
      implementation = "broker";
      packages = [pkgs.gcr pkgs.dconf];
    };

    hardware.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    programs.dconf.enable = true;

    services.udev.packages = with pkgs; [gnome.gnome-settings-daemon];

    security = {
      # allow wayland lockers to unlock the screen
      pam.services.swaylock.text = "auth include login";
      # userland niceness
      rtkit.enable = true;
    };

    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        #  inputs.xdg-portal-hyprland.packages.${pkgs.system}.default
      ];
    };

    services.greetd = {
      enable = true;
      settings = {
        default_session.command = let
          gtkgreetStyle = pkgs.writeText "greetd-gtkgreet.css" ''
            window {
              background-position: center;
              background-repeat: no-repeat;
              background-size: cover;
              background-color: black;
            }
            #body > box > box > label {
              text-shadow: 0 0 3px #1e1e2e;
              color: #f5e0dc;
            }
            entry {
              color: #f5e0dc;
              background: rgba(30, 30, 46, 0.8);
              border-radius: 16px;
              box-shadow: 0 0 5px #1e1e2e;
            }
            #clock {
              color: #f5e0dc;
              text-shadow: 0 0 3px #1e1e2e;
            }
            .text-button { border-radius: 16px; }
          '';
          #in "${pkgs.dbus}/bin/dbus-run-session ${pkgs.cage}/bin/cage -s -- ${pkgs.greetd.gtkgreet} -l -s ${gtkgreetStyle}";
          #in "${pkgs.cage}/bin/cage -s ${pkgs.greetd.gtkgreet}/bin/gtkgreet -- -l -s ${gtkgreetStyle}";
        in
          sway-kiosk "${pkgs.greetd.gtkgreet}/bin/gtkgreet -l &>/dev/null -s ${gtkgreetStyle} -l";
        initial_session = {
          command = "Hyprland";
          user = "christoph";
        };
      };
    };

    environment.etc."greetd/environments".text = ''
      sway
      Hyprland
      fish
    '';

    services.geoclue2.enable = true;
    home-manager.users.${config.conf.users.user} = {
      home.packages = with pkgs; [
        pulseaudio
        waypipe
        wf-recorder
        wl-clipboard
        libappindicator-gtk3
        brightnessctl
        swaylock-effects

        libreoffice-fresh
        hunspell
        hunspellDicts.de_DE

        gfn-electron
        gtk-frdp
        moonlight-qt

        kate
      ];

      home.persistence = {
        "/persist/home/christoph".directories = [".config/libreoffice" ".config/GeForce\ NOW"];
      };
      home.sessionVariables = {
        MOZ_ENABLE_WAYLAND = "true";
        QT_QPA_PLATFORM = "wayland";
        LIBSEAT_BACKEND = "logind";
      };

      dconf.enable = true;

      services.gammastep = {
        enable = false;
        provider = "geoclue2";
        temperature = {
          day = 6000;
          night = 4600;
        };
        settings = {
          general.adjustment-method = "wayland";
        };
      };

      services.wlsunset = {
        enable = true;
        longitude = "52.37052";
        latitude = "9.73322";
        temperature.day = 6500;
        temperature.night = 3500;
      };

      # services.swayidle = {
      #   enable = true;
      #   extraArgs = ["idlehint" "20"];
      #   events = [
      #     {
      #       event = "before-sleep";
      #       command = "${pkgs.swaylock-effects}/bin/swaylock -fF";
      #     }
      #     {
      #       event = "lock";
      #       command = "${pkgs.swaylock-effects}/bin/swaylock -fF";
      #     }
      #   ];
      #   timeouts = [
      #     {
      #       timeout = 300;
      #       command = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl dispatch dpms off";
      #       resumeCommand = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl dispatch dpms on";
      #     }
      #     {
      #       timeout = 310;
      #       command = "${pkgs.systemd}/bin/loginctl lock-session";
      #     }
      #     {
      #       timeout = 500;
      #       command = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl dispatch dpms on";
      #     }
      #     {
      #       timeout = 502;
      #       command = "${pkgs.systemd}/bin/systemctl hybrid-sleep";
      #     }
      #   ];
      # };

      # systemd.user.services.swayidle.Install.WantedBy = lib.mkForce ["hyprland-session.target"];

      programs.mako = {
        enable = true;
        borderSize = 3;
        padding = "20";
        margin = "30";
        width = 500;
        height = 600;
        defaultTimeout = 10000;
      };

      programs.swaylock = {
        settings = {
          effect-blur = "20x3";
          fade-in = 0.1;

          font = config.conf.fonts.serif.name;
          font-size = 15;

          line-uses-inside = true;
          disable-caps-lock-text = true;
          indicator-caps-lock = true;
          indicator-radius = 40;
          indicator-idle-visible = true;
          image = "${config.conf.theme.wallpaper}";

          ring-color = "${config.scheme.base02-hex}";
          inside-wrong-color = "${config.scheme.base08-hex}";
          ring-wrong-color = "${config.scheme.base08-hex}";
          key-hl-color = "${config.scheme.base0B-hex}";
          bs-hl-color = "${config.scheme.base08-hex}";
          ring-ver-color = "${config.scheme.base09-hex}";
          inside-ver-color = "${config.scheme.base09-hex}";
          inside-color = "${config.scheme.base01-hex}";
          text-color = "${config.scheme.base07-hex}";
          text-clear-color = "${config.scheme.base01-hex}";
          text-ver-color = "${config.scheme.base01-hex}";
          text-wrong-color = "${config.scheme.base01-hex}";
          text-caps-lock-color = "${config.scheme.base07-hex}";
          inside-clear-color = "${config.scheme.base0C-hex}";
          ring-clear-color = "${config.scheme.base0C-hex}";
          inside-caps-lock-color = "${config.scheme.base09-hex}";
          ring-caps-lock-color = "${config.scheme.base02-hex}";
          separator-color = "${config.scheme.base02-hex}";
        };
      };
    };
  };
}
