{
  config,
  pkgs,
  lib,
  ...
}: {
  home.packages = [pkgs.wayvnc];

  xdg.configFile."wayvnc/config".text = ''
    port=5901
  '';

  systemd.user.services.wayvnc = {
    Unit = {
      Description = "a VNC server for wlroots based Wayland compositors";
      After = ["graphical-session-pre.target"];
      PartOf = ["graphical-session.target"];
    };

    Service = {
      Restart = "on-failure";
      ExecStart = ''        ${pkgs.wayvnc}/bin/wayvnc 0.0.0.0
      '';
    };

    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };
}
