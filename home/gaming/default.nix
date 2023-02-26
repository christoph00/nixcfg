{
  pkgs,
  lib,
  ...
}: let
  desktopSteam = pkgs.makeDesktopItem {
    name = "Steam Service";
    desktopName = "Steam Service";
    exec = "${pkgs.systemd}/bin/systemctl --user start steam.service";
    icon = "steam";
    categories = ["Game"];
    terminal = false;
  };
in {
  home.sessionVariables.STEAM_EXTRA_COMPAT_TOOLS_PATHS = pkgs.proton-ge;

  home.packages = with pkgs; [
    steam-with-packages
    gamehub
    gamescope
    gamemode
    proton-ge
    lutris

    desktopSteam
  ];

  systemd.user.services = {
    steam = {
      Unit.Description = "Steam Client";
      Install.WantedBy = ["graphical-session.target"];
      Unit.PartOf = ["graphical-session.target"];
      Unit.Environment = ''
        STEAM_EXTRA_COMPAT_TOOLS_PATHS = "${pkgs.proton-ge}";

      '';
      #RADV_PERFTEST = "gpl";

      Service = {
        StartLimitInterval = 5;
        StartLimitBurst = 1;
        ExecStart = "${pkgs.steam-with-packages}/bin/steam -language german -silent";
        Type = "simple";
        Restart = "on-failure";
      };
    };
    "steam-appid@" = {
      Unit.Description = "Steam Game %i";
      Unit.PartOf = ["steam.service"];

      Service = {
        StartLimitInterval = 5;
        StartLimitBurst = 1;
        ExecStart = "${pkgs.steam-with-packages}/bin/steam steam://rungameid/%i";
        Type = "oneshot";
      };
    };
  };
}
