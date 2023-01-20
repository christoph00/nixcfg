{
  config,
  lib,
  pkgs,
  ...
}: let
  config = ''
    cert = /var/lib/acme/net.r505.de/full.pem
    pkey = /var/lib/acme/net.r505.de/key.pem
    origin_web_ui_allowed = wan
    origin_pin_allowed = wan
    adapter_name = /dev/dri/renderD128
    hevc_mode = 1
    fps = [30, 60]
    resolutions = [
      352x240,
      480x360,
      858x480,
      1280x720,
      1920x1080,
      2560x1080,
      3440x1440,
      1920x1200,
      3860x2160,
      3840x1600,
    ]
  '';
  configFile = pkgs.writeTextFile {
    name = "sunshine.conf";
    text = config;
  };
in {
  systemd.services.sunshine = {
    description = "Sunshine Gamestream host";
    wantedBy = ["graphical-session.target"];

    serviceConfig = {
      Type = "simple";
      Environment = "HOME=/var/lib/sunshine";
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /var/lib/sunshine/.config";
      ExecStart = "${pkgs.sunshine}/bin/sunshine ${configFile}";
    };
  };

  networking.firewall.allowedTCPPorts = [47984 47989 47990 48010];
  networking.firewall.allowedUDPPorts = [47998 47999 48000 48002];

  environment.persistence."/nix/persist".directories = ["/var/lib/sunshine"];

  programs.steam.enable = true;
  hardware = {
    xone.enable = true;
  };
}
