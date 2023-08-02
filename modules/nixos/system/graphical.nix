{
  config,
  lib,
  ...
}:
with lib; {
  config = mkIf (builtins.elem config.nos.type ["desktop" "laptop"]) {
    greetd = {
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

    gnome = {
      glib-networking.enable = true;
      gnome-keyring.enable = true;
    };

    logind = {
      lidSwitch = "suspend-then-hibernate";
      lidSwitchExternalPower = "suspend-then-hibernate";
      extraConfig = ''
        HandlePowerKey=suspend-then-hibernate
        HibernateDelaySec=3600
      '';
    };
  };
}
