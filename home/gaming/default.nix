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
    categories = [ "Games" ];
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

  systemd.user.services.steam = {
    Unit.Description = "Steam Client";
    Install.WantedBy = ["graphical-session.target"];
    Unit.PartOf = ["graphical-session.target"];
    Service.Type = "simple";
    Service.Restart = "on-failure";
    Unit.Environment = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = pkgs.proton-ge;
      #RADV_PERFTEST = "gpl";
    };
    script = ''
      ${pkgs.steam-with-packages}/bin/steam -language german -silent
    '';
  };
}
