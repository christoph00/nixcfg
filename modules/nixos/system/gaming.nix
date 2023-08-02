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
    programs = {
      steam.enable = true;
      steam.package = self'.packages.steam-with-packages;
      gamemode = {
        enable = true;
        settings = {
          custom = {
            start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
            end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
          };
        };
      };
    };
    systemd.extraConfig = "DefaultLimitNOFILE=1048576";
  };
}
