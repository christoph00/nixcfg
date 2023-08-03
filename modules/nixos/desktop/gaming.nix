{
  config,
  lib,
  pkgs,
  inputs',
  self',
  ...
}: {
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

    environment.systemPackages = [pkgs.gamescope];
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
      steam.package = pkgs.steam.override {
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
      gamemode = {
        enable = true;
      };
    };
    systemd.extraConfig = "DefaultLimitNOFILE=1048576";
  };
}
