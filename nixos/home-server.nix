{
  pkgs,
  config,
  lib,
  ...
}: {
  networking.firewall.allowedTCPPorts = [1883 53 8096 8030 80 443 2022 9100 1514 514 8080];
  networking.firewall.allowedUDPPorts = [53 1514 514];

  environment.persistence."/nix/persist" = {
    directories = [
      {
        directory = "/var/lib/prometheus2";
        user = "prometheus";
        group = "prometheus";
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
    phockup
  ];

  age.secrets.cf-dyndns.file = ../secrets/cf-dyndns;

  services.cloudflare-dyndns = {
    enable = true;
    ipv6 = true;
    proxied = false;
    domains = ["ha.r505.de" "data.r505.de" "media.r505.de" "fotos.r505.de"];
    apiTokenFile = config.age.secrets.cf-dyndns.path;
  };

  networking.hosts = {
    "192.168.2.50" = config.services.cloudflare-dyndns.domains;
  };

  virtualisation.oci-containers.containers.gallery = {
    ports = ["0.0.0.0:3001:3000"];
    image = "xemle/home-gallery";
    user = "994:256";
    volumes = [
      "/nix/persist/sftpgo/gallery:/data"
      "/mnt/userdata/christoph/Bilder:/data/Bilder"
    ];
    cmd = ["run" "server"];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/jellyfin/media 0770 jellyfin media"
    "L /var/lib/jellyfin/media/Movies - - - - /media/data-hdd/Movies"
    "L /var/lib/jellyfin/media/TVShows - - - - /media/data-hdd/TVShows"

    "d /home/christoph/media 0770 christoph media"
    "L /home/christoph/media/Movies - - - - /media/data-hdd/Movies"
    "L /home/christoph/media/TVShows - - - - /media/data-hdd/TVShows"

    "L /home/christoph/Downloads - - - - /media/data-ssd/Downloads"
  ];
}
