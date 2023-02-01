{
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    steam-with-packages
    gamescope
    protontricks
    proton-caller
    proton-ge
    lutris
    vulkan-loader
    vulkan-tools
  ];

  home.sessionVariables.STEAM_EXTRA_COMPAT_TOOLS_PATHS = pkgs.proton-ge;

  home.persistence = {
    "/nix/persist/games/christoph" = {
      allowOther = true;
      directories = [
        ".local/share/Paradox Interactive"
        ".paradoxlauncher"
        ".local/share/Steam"
        "Games"
      ];
      files = [".steam/steam.token" ".steam/registry.vdf"];
    };
  };

  # Start Steam on Login
  systemd.user.services.steam = {
    Unit.Description = "Steam Client";
    Install.WantedBy = ["graphical-session.target"];
    Unit.PartOf = ["graphical-session.target"];
    Service.Type = "simple";
    Service.ExecStart = "${pkgs.steam-with-packages}/bin/steam -silent";
    Service.Restart = "on-failure";
  };
}
