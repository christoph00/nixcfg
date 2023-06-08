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

  services.nginx.virtualHosts."media.r505.de" = {
    http2 = true;
    forceSSL = true;
    useACMEHost = "r505.de";
    locations = {
      "/".proxyPass = "http://127.0.0.1:8096";
    };
  };

  users.users.nginx.extraGroups = ["acme"];

}
