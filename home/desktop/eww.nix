{
  pkgs,
  config,
  ...
}: let
  eww-yuck = pkgs.writeText "eww.yuck" ''
    ;; VARS
    (defpoll clock-time :interval "10s" "date +'%H:%M'")


  '';

  eww-scss = pkgs.writeText "eww.scss" ''


  '';

  eww-config = pkgs.linkFarm "eww-config" [
    {
      name = "eww.yuck";
      path = eww-yuck;
    }
    {
      name = "eww.scss";
      path = eww-scss;
    }
  ];
in {
  programs.eww.enable = true;
  programs.eww.configDir = eww-config;
  systemd.user.services.eww = {
    Unit = {
      Description = "EWW Daemon";
      PartOf = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${config.programs.eww.package}/bin/eww daemon --no-daemonize";
      Restart = "on-failure";
    };
    Install.WantedBy = ["graphical-session.target"];
  };
}
