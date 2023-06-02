{
  pkgs,
  config,
  lib,
  ...
}: {
  environment.persistence."/nix/persist" = {
    directories = [
      {
        directory = "/var/lib/jellyfin";
        inherit (config.services.jellyfin) user group;
      }
      {
        directory = "/var/lib/sabnzbd";
        inherit (config.services.sabnzbd) user group;
      }
    ];
  };

  environment.systemPackages = with pkgs; [
    rclone
    git
    tmux
    wget
    btrfs-progs
    unrar
    bottom
    systemd-rest
    xplr
    unzip
    media-sort
    ffmpeg-full
  ];

  users.users.jellyfin.extraGroups = ["media"];
  services.jellyfin = {
    enable = true;
    openFirewall = false;
  };

  services.jellyseerr.enable = true;

  services.nginx.virtualHosts."media.r505.de" = {
    http2 = true;
    forceSSL = true;
    useACMEHost = "r505.de";
    locations = {
      "/".proxyPass = "http://127.0.0.1:8080";
    };
  };


  services.sabnzbd = {
    enable = true;
    group = "media";
  };


}
