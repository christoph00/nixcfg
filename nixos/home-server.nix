{
  pkgs,
  config,
  lib,
  ...
}: {
  networking.firewall.allowedTCPPorts = [1883 53 8096 8030 80 443 2022];
  networking.firewall.allowedUDPPorts = [53];

  services.nginx = {
    enable = true;
    statusPage = true;
    commonHttpConfig = ''
      set_real_ip_from 103.21.244.0/22;
      set_real_ip_from 103.22.200.0/22;
      set_real_ip_from 103.31.4.0/22;
      set_real_ip_from 104.16.0.0/13;
      set_real_ip_from 104.24.0.0/14;
      set_real_ip_from 108.162.192.0/18;
      set_real_ip_from 131.0.72.0/22;
      set_real_ip_from 141.101.64.0/18;
      set_real_ip_from 162.158.0.0/15;
      set_real_ip_from 172.64.0.0/13;
      set_real_ip_from 173.245.48.0/20;
      set_real_ip_from 188.114.96.0/20;
      set_real_ip_from 190.93.240.0/20;
      set_real_ip_from 197.234.240.0/22;
      set_real_ip_from 198.41.128.0/17;
      set_real_ip_from 2400:cb00::/32;
      set_real_ip_from 2606:4700::/32;
      set_real_ip_from 2803:f800::/32;
      set_real_ip_from 2405:b500::/32;
      set_real_ip_from 2405:8100::/32;
      set_real_ip_from 2c0f:f248::/32;
      set_real_ip_from 2a06:98c0::/29;
      real_ip_header CF-Connecting-IP;
    '';
  };
  users.users.nginx.extraGroups = ["acme"];

  users.users.sftpgo.extraGroups = ["media"];
  services.sftpgo = {
    enable = true;
    package = pkgs.my-sftpgo;
    settings = {
      common = {
        proxy_allowed = "127.0.0.1/32";
        proxy_protocol = 1;
      };
      data_provider = {
        driver = "bolt";
        name = "sftpgo.db";
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

  services.nginx.virtualHosts."nas.net.r505.de" = {
    forceSSL = true;
    serverName = "nas.net.r505.de";
    useACMEHost = "net.r505.de";
    locations."/" = {
      proxyPass = "http://127.0.0.1:8080";
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
    ];
  };

  environment.systemPackages = with pkgs; [rclone git tmux wget btrfs-progs unrar bottom systemd-rest];

  users.users.jellyfin.extraGroups = ["media"];
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  services.nginx.virtualHosts."media.net.r505.de" = {
    forceSSL = true;
    serverName = "media.net.r505.de";
    useACMEHost = "net.r505.de";
    locations."/" = {
      proxyPass = "http://localhost:8096";
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

  # users.users.sabnzbd.extraGroups = ["media"];
  # services.sabnzbd = {
  #   enable = true;
  # };

  # services.nginx.virtualHosts."nzb.net.r505.de" = {
  #   forceSSL = true;
  #   serverName = "nzb.net.r505.de";
  #   useACMEHost = "net.r505.de";
  #   locations."/" = {
  #     proxyPass = "http://localhost:6789";
  #   };
  # };

  users.users.aria2.extraGroups = ["media"];
  users.users.christoph.extraGroups = ["aria2"];
  services.aria2 = {
    enable = true;
    #openPorts = true;
    downloadDir = "/media/data-ssd/Downloads";
    extraArguments = "--rpc-listen-all --remote-time=true";
  };
  services.nginx.virtualHosts."dl.net.r505.de" = {
    forceSSL = true;
    serverName = "dl.net.r505.de";
    useACMEHost = "net.r505.de";
    locations = {
      "/".root = "${pkgs.ariaNg}";
      "/jsonrpc" = {
        proxyPass = "http://localhost:6800/jsonrpc";
        extraConfig = ''
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";
          proxy_set_header Host $host;
          proxy_set_header X-Forwarded-Host $host:$server_port;
          proxy_set_header X-Forwarded-Server $host;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        '';
      };
    };
  };
}
