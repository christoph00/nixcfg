{
  pkgs,
  lib,
  ...
}: let
  steam-with-pkgs = pkgs.steam.override {
    extraPkgs = pkgs:
      with pkgs; [
        xorg.libXcursor
        xorg.libXi
        xorg.libXinerama
        xorg.libXScrnSaver
        libpng
        libpulseaudio
        libvorbis
        stdenv.cc.cc.lib
        libkrb5
        keyutils
        gamescope
      ];
  };
in {
  home.packages = with pkgs; [
    steam-with-pkgs
    gamescope
    protontricks
    sunshine
    wayvnc
  ];
  home.persistence = {
    "/nix/persist/games/christoph" = {
      allowOther = true;
      directories = [
        ".local/share/Paradox Interactive"
        ".paradoxlauncher"
        {
          directory = ".local/share/Steam";
          method = "symlink";
        }
      ];
    };
  };

  # Start Steam on Login
  systemd.user.services.steam = {
    Unit.Description = "Steam Client";
    Install.WantedBy = ["graphical-session.target"];
    Unit.PartOf = ["graphical-session.target"];
    Service.Type = "simple";
    Service.ExecStart = "${steam-with-pkgs}/bin/steam -silent";
    Service.Restart = "on-failure";
  };
}
