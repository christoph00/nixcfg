{
  config,
  lib,
  pkgs,
  inputs',
  self',
  ...
}: let
  gamescopeSteam = pkgs.makeDesktopItem {
    name = "Steam (Gamescope)";
    exec = "${pkgs.gamescope}/bin/gamescope -W 2560 -H 1440 -w 2560 -h 1440 -e -- ${pkgs.steam}/bin/steam -fulldesktopres";
    comment = "Steam big picture running in gamescope";
    desktopName = "Steam (Gamescope)";
    categories = ["Game"];
  };

  gamescopeSteamFull = pkgs.makeDesktopItem {
    name = "Steam (Gamescope Fullscreen)";
    exec = "${pkgs.gamescope}/bin/gamescope -W 2560 -H 1440 -w 2560 -h 1440 -f -e -- ${pkgs.steam}/bin/steam -tenfoot -steamos -fulldesktopres";
    comment = "Steam big picture running in gamescope";
    desktopName = "Steam (Gamescope)";
    categories = ["Game"];
  };

  steam = pkgs.steam.override {
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
        gamemode
        mangohud
      ];
  };
in {
  config = lib.mkIf config.nos.desktop.gaming {
    boot.kernel.sysctl."vm.max_map_count" = 262144;

    hardware.opengl.driSupport32Bit = true;
    hardware.pulseaudio.support32Bit = true;
    hardware.steam-hardware.enable = true;
    security.pam.loginLimits = [
      {
        domain = "*";
        item = "memlock";
        type = "-";
        value = "unlimited";
      }
      {
        domain = "*";
        item = "nofile";
        type = "soft";
        value = "unlimited";
      }
      {
        domain = "*";
        item = "nofile";
        type = "hard";
        value = "unlimited";
      }
    ];

    environment.systemPackages = [pkgs.gamescope gamescopeSteamFull gamescopeSteam];
    environment.sessionVariables = {
      PRESSURE_VESSEL_FILESYSTEMS_RO = "${inputs'.nix-gaming.packages.proton-ge}";
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = ["${inputs'.nix-gaming.packages.proton-ge}"];
    };
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "steam"
        "steam-original"
        "steam-runtime"
        "steam-run"
      ];
    programs = {
      steam.enable = true;
      steam.package = steam;
      steam.gamescopeSession.enable = true;
      gamemode = {
        enable = true;
      };
      gamescope.enable = true;
    };
    systemd.extraConfig = "DefaultLimitNOFILE=1048576";
  };
}
