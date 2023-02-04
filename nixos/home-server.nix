{
  pkgs,
  config,
  lib,
  ...
}: {
  networking.firewall.allowedTCPPorts = [1883 53 8096 8030 80 443 2022 9100];
  networking.firewall.allowedUDPPorts = [53];

  users.users.sftpgo.extraGroups = ["media"];
  services.sftpgo = {
    enable = true;
    package = pkgs.my-sftpgo;
    settings = {
      common = {
        proxy_allowed = ["127.0.0.1/32" "100.0.0.0/8"];
        proxy_protocol = 1;
      };
      data_provider = {
        driver = "bolt";
        name = "sftpgo.db";
      };
      webdavd = {
        bindings = [
          {
            port = 8033;
          }
        ];
      };
      httpd = {
        bindings = [
          {
            proxy_allowed = "127.0.0.1/32";
            client_ip_proxy_header = "X-Real-IP";
            branding = {
              web_client = {
                name = "NAS";
                short_name = "NAS";
              };
            };
          }
        ];
      };
    };
  };

  environment.persistence."/nix/persist" = {
    directories = [
      {
        directory = "/var/lib/sftpgo";
        inherit (config.services.sftpgo) user group;
      }
      {
        directory = "/var/lib/jellyfin";
        inherit (config.services.jellyfin) user group;
      }
      # {
      #   directory = "/var/lib/sabnzbd";
      #   inherit (config.services.sabnzbd) user group;
      # }
      {
        directory = "/var/lib/prometheus2";
        user = "prometheus";
        group = "prometheus";
      }
    ];
  };

  environment.systemPackages = with pkgs; [rclone git tmux wget btrfs-progs unrar bottom systemd-rest xplr unzip media-sort];

  environment.shellAliases = {
    unrar-all = ''for file in *.rar; do ${pkgs.unrar}/bin/unrar e "$file"; done'';
  };

  users.users.jellyfin.extraGroups = ["media"];
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  services.traefik.dynamicConfigOptions.http = {
    routers = {
      media = {
        rule = "Host(`media.net.r505.de`)";
        tls = {certResolver = "cloudflare";};
        service = "jellyfin";
      };
      aria2rpc = {
        rule = "Host(`dl.net.r505.de`) && Path(`jsonrpc`)";
        tls = {certResolver = "cloudflare";};
        service = "aira2rpc";
      };
      nas = {
        rule = "Host(`nas.net.r505.de`)";
        tls = {certResolver = "cloudflare";};
        service = "sftpgo-web";
      };
      # aria2web = {
      #   rule = "Host(`dl.net.r505.de`)";
      #   tls = {certResolver = "cloudflare";};
      #   service = "aira2web";
      # };
    };
    services = {
      jellyfin = {
        loadBalancer = {
          servers = [{url = "http://localhost:8096";}];
        };
      };
      aria2rpc = {
        loadBalancer = {
          servers = [{url = "http://localhost:6800/jsonrpc";}];
        };
      };
      sftpgo-web = {
        loadBalancer = {
          servers = [{url = "http://localhost:8080/jsonrpc";}];
        };
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/jellyfin/media 0770 jellyfin media"
    "L /var/lib/jellyfin/media/Movies - - - - /media/data-hdd/Movies"
    "L /var/lib/jellyfin/media/TVShows - - - - /media/data-hdd/TVShows"

    "d /home/christoph/media 0770 christoph media"
    "L /home/christoph/media/Movies - - - - /media/data-hdd/Movies"
    "L /home/christoph/media/TVShows - - - - /media/data-hdd/TVShows"

    "L /home/christoph/Downloads - - - - /media/data-ssd/Downloads"

    # "d /var/lib/sabnzbd/media 0770 sabnzbd media"
    # "L /var/lib/sabnzbd/media/Movies - - - - /media/data-hdd/Movies"
    # "L /var/lib/sabnzbd/media/TVShows - - - - /media/data-hdd/TVShows"
    # "d /var/lib/sabnzbd/Downloads 0770 sabnzbd media"
    # "L /var/lib/sabnzbd/Downloads - - - - /media/data-ssd/Downloads"
  ];

  users.users.aria2.extraGroups = ["media"];
  users.users.christoph.extraGroups = ["aria2"];
  services.aria2 = {
    enable = true;
    #openPorts = true;
    downloadDir = "/media/data-ssd/Downloads";
    extraArguments = "--rpc-listen-all --remote-time=true";
  };

  services.prometheus = {
    enable = true;
    port = 9001;
    scrapeConfigs = [
      {
        job_name = "erx";
        static_configs = [
          {
            targets = ["erx.lan.net.r505.de:9100"];
          }
        ];
      }
      {
        job_name = "uap";
        static_configs = [
          {
            targets = ["uap.lan.net.r505.de:9100"];
          }
        ];
      }
      {
        job_name = "futro";
        static_configs = [
          {
            targets = ["127.0.0.1:9002" "127.0.0.1:8082"];
          }
        ];
      }
      {
        job_name = "oc1";
        static_configs = [
          {
            targets = ["oc1.cama-boa.ts.net:9002" "oc1.cama-boa.ts.net:8082"];
          }
        ];
      }
      {
        job_name = "oc2";
        static_configs = [
          {
            targets = ["oc2.cama-boa.ts.net:9002" "oc2.cama-boa.ts.net:8082"];
          }
        ];
      }
      {
        job_name = "oca";
        static_configs = [
          {
            targets = ["oca.cama-boa.ts.net:9002"];
          }
        ];
      }
    ];
  };
}
