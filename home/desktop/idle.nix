{
  pkgs,
  config,
  lib,
  ...
}: {
  services.swayidle = {
    enable = true;
    # events = [
    #   {
    #     event = "before-sleep";
    #     command = "${pkgs.systemd}/bin/loginctl lock-session";
    #   }
    #   {
    #     event = "lock";
    #     command = "${pkgs.swaylock-effects}/bin/swaylock -fF";
    #   }
    # ];
    timeouts = [
      {
        timeout = 300;
        command = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl dispatch dpms off";
        resumeCommand = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl dispatch dpms on";
      }
    ];
  };
  systemd.user.services.swayidle.Install.WantedBy = lib.mkForce ["hyprland-session.target"];
}
