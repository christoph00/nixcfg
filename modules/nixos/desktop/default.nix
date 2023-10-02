{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.desktop;
in {
  options.chr.desktop = with types; {
    enable = mkOption {
      type = types.bool;
      default = builtins.elem config.chr.type ["desktop" "laptop"];
    };
    wm = mkOption {
      type = types.enum ["Hyprland" "plasma"];
      default = "Hyprland";
    };
    autologin = mkOption {
      type = types.bool;
      default = true;
    };
    bar = mkOption {
      type = types.enum ["waybar" "eww" "ags" "none"];
      default = "waybar";
    };
  };

  config = mkIf cfg.enable {
    # Disable mitigations on desktop
    boot.kernelParams = [
      "splash"
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
    boot.loader.timeout = lib.mkForce 0;

    boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

    hardware.opengl = {
      enable = true;
      driSupport = true;
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
      };
    };

    environment.etc."greetd/environments".text = ''
      ${lib.optionalString (config.chr.desktop.wm == "Hyprland") "Hyprland"}
      bash
    '';

    services.greetd = {
      enable = true;
      vt = 2;
      restart = !config.chr.desktop.autologin;
      settings = {
        initial_session = mkIf config.chr.desktop.autologin {
          command = "${config.chr.desktop.wm}";
          user = "${config.chr.user.name}";
        };

        default_session =
          if (!config.chr.desktop.autologin)
          then {
            command = lib.concatStringsSep " " [
              (lib.getExe pkgs.greetd.tuigreet)
              "--time"
              "--remember"
              "--remember-user-session"
              "--asterisks"
              "--sessions '${sessionPath}'"
            ];
            user = "greeter";
          }
          else {
            command = "${config.chr.desktop.wm}";
            user = "${config.chr.mainUser}";
          };
      };
    };
    #suspend-then-hibernate
    services.logind = {
      killUserProcesses = true;
      lidSwitch = "hibernate";
      lidSwitchExternalPower = "hibernate";
      extraConfig = ''
        HandlePowerKey=hibernate
        HibernateDelaySec=3600
      '';
    };

    xdg.portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-gtk];
    };

    fonts = {
      packages = with pkgs; [
        material-symbols
        lexend
        noto-fonts
        noto-fonts-emoji
        roboto
        (nerdfonts.override {fonts = ["FiraCode" "JetBrainsMono" "Iosevka"];})
      ];
      fontconfig.defaultFonts = {
        serif = ["Roboto Serif" "Noto Color Emoji"];
        sansSerif = ["Roboto" "Noto Color Emoji"];
        monospace = ["JetBrainsMono Nerd Font" "Noto Color Emoji"];
        emoji = ["Noto Color Emoji"];
      };
    };

    hardware.logitech.wireless.enable = true;
    networking.networkmanager.enable = lib.mkForce true;

    programs.dconf.enable = true;

    services.fwupd.enable = true;

    services = {
      gnome.gnome-keyring.enable = true;

      upower.enable = true;
    };

    systemd.services = {
      seatd = {
        enable = true;
        description = "Seat management daemon";
        script = "${pkgs.seatd}/bin/seatd -g wheel";
        serviceConfig = {
          Type = "simple";
          Restart = "always";
          RestartSec = "1";
        };
        wantedBy = ["multi-user.target"];
      };
    };

    programs.xwayland.enable = true;

    hardware.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = false;
      wireplumber.enable = true;
    };
    hardware.uinput.enable = true;

    environment.systemPackages = [pkgs.gtklock pkgs.seatd pkgs.ddcutil pkgs.ddcui];
    # services.udev.packages = [ pkgs.light ];
    security.polkit.enable = true;
    security.pam.services.gtklock.text = "auth include login\n";

    services.dbus = {
      enable = true;
      # implementation = "broker";
      packages = [pkgs.gcr pkgs.dconf];
    };

    virtualisation = {
      podman = {
        enable = true;
        defaultNetwork.settings = {
          dns_enabled = true;
        };
      };
    };
  };
}
