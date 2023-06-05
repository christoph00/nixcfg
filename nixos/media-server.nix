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
      "/".proxyPass = "http://127.0.0.1:8096";
    };
  };



  users.users.nginx.extraGroups = ["acme"];

  systemd.services.media-sort = {
    description = "Media-Sort TVShows";
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      User = "sftpgo";
      Type = "simple";
      ExecStart = "${pkgs.media-sort}/bin/media-sort -t /media/data-hdd/TVShows -m /media/data-hdd/Movies  -a 80 -w -r /mnt/ncdata/christoph/Incoming/TVShows";
      Restart = "always";
      RestartSec = "20";
    };
  };
}
