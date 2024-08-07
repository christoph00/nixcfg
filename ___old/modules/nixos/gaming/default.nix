{
  options,
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.gaming;

  steam = pkgs.steam.override {
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
    extraLibraries = p: with p; [(lib.getLib pkgs.networkmanager)];
  };
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
in {
  options.chr.gaming = with types; {
    enable = mkBoolOpt (config.chr.type == "desktop") "Whether or not to enable Gaming Module.";
  };

  config = mkIf cfg.enable {
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

    environment.sessionVariables = {
      # PRESSURE_VESSEL_FILESYSTEMS_RO = "${inputs'.nix-gaming.packages.proton-ge}";
      # STEAM_EXTRA_COMPAT_TOOLS_PATHS = ["${inputs'.nix-gaming.packages.proton-ge}"];
    };

    systemd.user.services = {
      steam = {
        partOf = ["graphical-session.target"];
        environment = {
          SDL_VIDEODRIVER = "x11";
        };
        serviceConfig = {
          StartLimitInterval = 5;
          StartLimitBurst = 1;
          ExecStart = "${steam}/bin/steam -language german -silent -pipewire";
          Type = "simple";
          Restart = "on-failure";
        };
      };
    };
    systemd.extraConfig = "DefaultLimitNOFILE=1048576";

    programs.steam = {
      enable = true;
      package = steam;
      extraCompatPackages = [pkgs.proton-ge-bin];
    };
    programs.gamemode.enable = true;

    chr.home = {
      extraOptions = {
        home.packages = with pkgs; [
          gamehub
          gamescope
          gamemode
          protontricks
          radeontop
          rare
          heroic
          gogdl
        ];
      };
    };
  };
}
