{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  imports = [./gaming.nix ./hyprland.nix];
  config = mkIf (builtins.elem config.nos.type ["desktop" "laptop"]) {
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
    boot.loader.timeout = lib.mkForce 0;

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
      ${lib.optionalString (config.desktop.wm == "Hyprland") "Hyprland"}
      zsh
    '';

    services.greetd = {
      enable = true;
      vt = 2;
      restart = !config.nos.desktop.autologin;
      settings = {
        initial_session = mkIf config.nos.desktop.autologin {
          command = "${config.nos.desktop.wm}";
          user = "${config.nos.mainUser}";
        };

        default_session =
          if (!config.nos.desktop.autologin)
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
            command = "${config.nos.desktop.wm}";
            user = "${config.nos.mainUser}";
          };
      };
    };

    services.logind = {
      lidSwitch = "suspend-then-hibernate";
      lidSwitchExternalPower = "suspend-then-hibernate";
      extraConfig = ''
        HandlePowerKey=suspend-then-hibernate
        HibernateDelaySec=3600
      '';
    };

    xdg.portal = {
      enable = true;

      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
      ];
    };

    hardware.logitech.wireless.enable = true;
    networking.networkmanager.enable = lib.mkForce true;

    programs.dconf.enable = true;

    services.fwupd.enable = true;

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

    services.upower.enable = true;

    services.dbus = {
      enable = true;
      # implementation = "broker";
      # packages = [pkgs.gcr pkgs.dconf];
    };
  };
}
