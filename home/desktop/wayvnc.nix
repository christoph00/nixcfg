{
  config,
  pkgs,
  lib,
  ...
}: {
  home.packages = [pkgs.wayvnc];

  xdg.configFile."wayvnc/config".text = ''
    enable_auth=false
    address=0.0.0.0
    port=5901
    private_key_file=/etc/wayvnc/key.pem
    certificate_file=/etc/wayvnc/cert.pem
  '';

  systemd.user.services.wayvnc = {
    Unit = {
      Description = "a VNC server for wlroots based Wayland compositors";
      After = ["graphical-session-pre.target"];
      PartOf = ["graphical-session.target"];
    };

    Service = {
      Restart = "on-failure";
      ExecStart = ''
        ${pkgs.wayvnc}/bin/wayvnc
      '';
    };

    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };
}
