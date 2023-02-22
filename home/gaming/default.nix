{
  pkgs,
  lib,
  ...
}: {
  home.sessionVariables.STEAM_EXTRA_COMPAT_TOOLS_PATHS = pkgs.proton-ge;

  home.packages = [pkgs.ddccontrol pkgs.steam-with-packages pkgs.gamehub pkgs.gamescope pkgs.gamemode pkgs.proton-ge];

  # Start Steam on Login
  # systemd.user.services.steam = {
  #   Unit.Description = "Steam Client";
  #   Install.WantedBy = ["graphical-session.target"];
  #   Unit.PartOf = ["graphical-session.target"];
  #   Service.Type = "simple";
  #   Service.Restart = "on-failure";
  #   Unit.Environment = {
  #     STEAM_EXTRA_COMPAT_TOOLS_PATHS = pkgs.proton-ge;
  #     RADV_PERFTEST = "gpl";
  #   };
  #   script = ''
  #     ${pkgs.steam-with-packages}/bin/steam -language german -silent
  #   '';
  # };
}
