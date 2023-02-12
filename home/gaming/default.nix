{
  pkgs,
  lib,
  ...
}: {
  home.sessionVariables.STEAM_EXTRA_COMPAT_TOOLS_PATHS = pkgs.proton-ge;

  home.persistence = {
    "/nix/persist/games/christoph" = {
      allowOther = true;
      directories = [
        ".local/share/Paradox Interactive"
        ".paradoxlauncher"
        ".local/share/Steam"
        "Games"
        ".config/gamescope"
      ];
      #files = [".steam/steam.token" ".steam/registry.vdf"];
    };
  };

  # Start Steam on Login
  # systemd.user.services.steam = {
  #   Unit.Description = "Steam Client";
  #   Install.WantedBy = ["graphical-session.target"];
  #   Unit.PartOf = ["graphical-session.target"];
  #   Service.Type = "simple";
  #   Service.ExecStart = "${pkgs.steam-with-packages}/bin/steam -silent";
  #   Service.Restart = "on-failure";
  # };
}
