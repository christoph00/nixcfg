{
  pkgs,
  lib,
  self',
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
  home.packages = with pkgs; [
    gamehub
    gamescope
    gamemode
    protontricks
    radeontop

    rare
    heroic
    gogdl

    #  desktopSteam
  ];

  # home.file.".steam/root/compatibilitytools.d/Proton-GE".source = "${pkgs.proton-ge}";
  # home.sessionVariables.STEAM_EXTRA_COMPAT_TOOLS_PATHS = ["$HOME/.steam/root/compatibilitytools.d"];

  # systemd.user.services = {
  #   steam = {
  #     Unit.Description = "Steam Client";
  #     Install.WantedBy = ["graphical-session.target"];
  #     Unit.PartOf = ["graphical-session.target"];
  #     Service = {
  #       StartLimitInterval = 5;
  #       StartLimitBurst = 1;
  #       ExecStart = "${steam-with-packages}/bin/steam -language german -silent -newbigpicture -pipewire"; #
  #       Type = "simple";
  #       Restart = "on-failure";
  #     };
  #   };
  #   "steam-appid@" = {
  #     Unit.Description = "Steam Game %i";
  #     Unit.PartOf = ["steam.service"];

  #     Service = {
  #       StartLimitInterval = 5;
  #       StartLimitBurst = 1;
  #       ExecStart = "${steam-with-packages}/bin/steam steam://rungameid/%i";
  #       Type = "oneshot";
  #     };
  #   };
  #   "steam-bigpicture" = {
  #     Unit.Description = "Steam Big Picture";
  #     Unit.PartOf = ["steam.service"];

  #     Service = {
  #       StartLimitInterval = 5;
  #       StartLimitBurst = 1;
  #       ExecStart = "${steam-with-packages}/bin/steam -start steam://open/bigpicture";
  #       Type = "oneshot";
  #     };
  #   };
  # };

  programs.mangohud = {
    enable = true;
    settings = {
      preset = 1;
    };
  };
}
