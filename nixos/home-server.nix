{
  pkgs,
  config,
  lib,
  ...
}: {
  networking.firewall.allowedTCPPorts = [1883 53 8096 8030 80 443 2022 9100 1514 514];
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
    ffmpeg-full
    nodejs
  ];

  age.secrets.cf-dyndns.file = ../secrets/cf-dyndns;

  services.cloudflare-dyndns = {
    enable = true;
    ipv6 = true;
    proxied = false;
    domains = ["home.r505.de" "cloud.r505.de" "data.r505.de"];
    apiTokenFile = config.age.secrets.cf-dyndns.path;
  };

  networking.hosts = {
    "192.168.2.50" = config.services.cloudflare-dyndns.domains;
  };

  systemd.services.immich-server = {
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    environment = {
      NODE_ENV = "production";
      DB_HOSTNAME = "immich_postgres";
      DB_USERNAME = "immich";
      DB_PASSWORD = "immich";
      DB_DATABASE_NAME = "immich";
      UPLOAD_LOCATION = "/mnt/userdata/immich";
      TYPESENSE_API_KEY = "23942984928392";

      IMMICH_WEB_URL = "http://localhost:3000";
      IMMICH_SERVER_URL = "http://localhost:3001";
      IMMICH_MACHINE_LEARNING_URL = "http://localhost:3003";
    };
    serviceConfig = {
      ExecStart = "${pkgs.nodejs}/bin/node ${pkgs.immich-server}/dist/apps/immich/apps/immich/src/main.js";
    };
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_14;
    ensureDatabases = ["immich"];
    ensureUsers = [
      {
        name = "immich";
        ensurePermissions = {
          "DATABASE immich" = "ALL PRIVILEGES";
          "ALL TABLES IN SCHEMA public" = "ALL PRIVILEGES";
        };
      }
    ];
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
