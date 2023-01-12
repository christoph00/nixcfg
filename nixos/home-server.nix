{
  pkgs,
  config,
  ...
}: {
  networking.firewall.allowedTCPPorts = [1883 53 8096 8030 80 443];
  networking.firewall.allowedUDPPorts = [53];

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "christoph@asche.co";
    };
    certs."net.r505.de" = {
      domain = "*.net.r505.de";
      dnsProvider = "cloudflare";
      credentialsFile = config.age.secrets.cf-acme.path;
      dnsResolver = "1.1.1.1:53";
    };
  };

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
    openFirewall = true;
    settings = {
      data_provider = {
        driver = "bolt";
        name = "sftpgo.db";
      };
    };
  };

  environment.persistence."/nix/persist" = {
    directories = [
      {
        directory = "/var/lib/sftpgo";
        inherit (config.services.sftpgo) user group;
      }
    ];
  };

  environment.systemPackages = with pkgs; [rclone git tmux wget btrfs-progs unrar];

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

    "d /var/lib/nzbget/media 0770 nzbget media"
    "L /var/lib/nzbget/media/Movies - - - - /media/data-hdd/Movies"
    "L /var/lib/nzbget/media/TVShows - - - - /media/data-hdd/TVShows"
    "d /var/lib/nzbget/Downloads 0770 nzbget media"
    "L /var/lib/nzbget/Downloads - - - - /media/data-ssd/Downloads"
  ];

  users.users.nzbget.extraGroups = ["media"];
  services.nzbget = {
    enable = true;
    settings = {
      MainDir = "/data";
    };
  };

  services.nginx.virtualHosts."nzb.net.r505.de" = {
    forceSSL = true;
    serverName = "nzb.net.r505.de";
    useACMEHost = "net.r505.de";
    locations."/" = {
      proxyPass = "http://localhost:6789";
    };
  };
}
