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
    exec = "${pkgs.gamescope}/bin/gamescope -e -F fsr -S integer --framerate-limit 60 -r 60 -- ${steam}/bin/steam -fulldesktopres";
    comment = "Steam big picture running in gamescope";
    desktopName = "Steam (Gamescope)";
    categories = ["Game"];
  };

  gamescopeSteamFull = pkgs.makeDesktopItem {
    name = "Steam (Gamescope Fullscreen)";
    exec = "${pkgs.gamescope}/bin/gamescope -W 2560 -H 1440 -w 2560 -h 1440 -f -e -F fsr -S integer --framerate-limit 60 -r 60 -- ${steam}/bin/steam -tenfoot -steamos -fulldesktopres";
    comment = "Steam big picture running in gamescope";
    desktopName = "Steam (Fullscreen)";
    categories = ["Game"];
  };

  steam = inputs'.unfree.legacyPackages.steam.override {
    extraPkgs = pkgs:
      with pkgs; [
        xorg.libXcursor
        xorg.libXi
        xorg.libXinerama
        xorg.libXScrnSaver
        xorg.libXext
        xorg.libX11
        xorg.libXfixes
        libpng
        libpulseaudio
        libvorbis
        libgdiplus
        stdenv.cc.cc.lib
        libkrb5
        keyutils
        gamescope
        gamemode
        mangohud
      ];
    extraLibraries = p:
      with p; [
        (lib.getLib pkgs.networkmanager)
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

    environment.systemPackages = [pkgs.gamescope gamescopeSteamFull gamescopeSteam steam inputs'.nix-gaming.packages.wine-ge pkgs.heroic];
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
    systemd.user.services = {
      steam = {
        partOf = ["graphical-session.target"];
        environment = {
          SDL_VIDEODRIVER = "x11";
        };
        serviceConfig = {
          StartLimitInterval = 5;
          StartLimitBurst = 1;
          ExecStart = "${steam}/bin/steam -language german -silent -pipewire"; #
          Type = "simple";
          Restart = "on-failure";
        };
      };
    };
    programs = {
      steam.enable = true;
      steam.package = steam;
      # steam.gamescopeSession.enable = true;
      gamemode = {
        enable = true;
      };
      #gamescope.enable = true;
    };
    systemd.extraConfig = "DefaultLimitNOFILE=1048576";
  };
}
