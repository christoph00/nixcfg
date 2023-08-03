{
  pkgs,
  osConfig,
  config,
  lib,
  ...
}: {
  config = lib.mkIf (builtins.elem osConfig.nos.type ["desktop" "laptop"]) {
    services.swayidle = {
      enable = true;
      events = [
        {
          event = "before-sleep";
          command = "${pkgs.systemd}/bin/loginctl lock-session";
        }
        {
          event = "lock";
          command = "${pkgs.gtklock}/bin/gtklock-blur";
        }
      ];
      timeouts = [
        {
          timeout = 200;
          command = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl dispatch dpms off";
          resumeCommand = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl dispatch dpms on";
        }

        {
          timeout = 300;
          command = "systemctl suspend-then-hibernate";
        }
      ];
    };
    systemd.user.services.swayidle.Install.WantedBy = lib.mkForce ["hyprland-session.target"];
  };
}
