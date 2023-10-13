{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.gaming;
  desktopSteam = pkgs.makeDesktopItem {
    name = "Steam Service";
    desktopName = "Steam Service";
    exec = "${pkgs.systemd}/bin/systemctl --user start steam.service";
    icon = "steam";
    categories = ["Game"];
    terminal = false;
  };
in {
  options.chr.gaming = with types; {
    enable = mkBoolOpt (config.chr.type == "desktop") "Whether or not to enable Gaming Module.";
  };

  config = mkIf cfg.enable {
    programs.steam = {
      enable = true;
      package = pkgs.chr.steam;

    };
    chr.home = {
      extraOptions = {

        home.packages = with pkgs; [
          chr.steam
          gamehub
          gamescope
          gamemode
          protontricks
          radeontop

          rare
          heroic
          gogdl

          desktopSteam
        ];

        # home.file.".steam/root/compatibilitytools.d/Proton-GE".source = "${pkgs.proton-ge}";
        # home.sessionVariables.STEAM_EXTRA_COMPAT_TOOLS_PATHS = ["$HOME/.steam/root/compatibilitytools.d"];

        systemd.user.services = {
          steam = {
            Unit.Description = "Steam Client";
            Install.WantedBy = ["graphical-session.target"];
            Unit.PartOf = ["graphical-session.target"];
            Service = {
              StartLimitInterval = 5;
              StartLimitBurst = 1;
              ExecStart = "${pkgs.chr.steam}/bin/steam -language german -silent -newbigpicture -pipewire"; #
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
              ExecStart = "${pkgs.chr.steam}/bin/steam steam://rungameid/%i";
              Type = "oneshot";
            };
          };
          "steam-bigpicture" = {
            Unit.Description = "Steam Big Picture";
            Unit.PartOf = ["steam.service"];

            Service = {
              StartLimitInterval = 5;
              StartLimitBurst = 1;
              ExecStart = "${pkgs.chr.steam}/bin/steam -start steam://open/bigpicture";
              Type = "oneshot";
            };
          };
        };
      };
    };
  };
}
