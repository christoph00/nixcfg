# https://github.com/Jovian-Experiments/Jovian-NixOS
{
  pkgs,
  lib,
  ...
}: {
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
  programs = {
    steam.enable = true;
    steam.package = pkgs.steam-with-packages;
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

  # systemd.user.services.x11-ownership = rec {
  #   serviceConfig.Type = "oneshot";
  #   script = ''
  #     ${pkgs.sudo}/bin/sudo chown -R christoph:users /tmp/.X11-unix
  #   '';
  #   after = ["graphical-session.target"];
  #   wants = after;
  #   wantedBy = ["graphical-session-pre.target"];
  # };

  # systemd.user.services.steamui = {
  #   description = "Steam UI";
  #   partOf = ["graphical-session.target"];
  #   script = "${steam-session}/bin/steam-session";
  # };
  # systemd.user.services.steam = {
  #   description = "Steam";
  #   partOf = ["graphical-session.target"];

  #   after = ["graphical-session.target"];
  #   wantedBy = ["graphical-session-pre.target"];

  #   environment = {
  #     STEAM_EXTRA_COMPAT_TOOLS_PATHS = pkgs.proton-ge;
  #   #  RADV_PERFTEST = "gpl";
  #   };
  #   script = ''
  #     ${pkgs.steam-with-packages}/bin/steam -language german -silent
  #   '';
  # };
}
