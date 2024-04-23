{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.services.nas;
in {
  options.chr.services.nas = with types; {
    enable = mkBoolOpt false "Enable NAS Service.";
    userdataDir = mkOpt (types.nullOr types.str) "/mnt/userdata" "NAS Userdata Dir.";
    webdav = mkBoolOpt true "Enable Webdav Service.";
    sftp = mkBoolOpt true "Enable Sftp Service.";
  };
  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [80 443 2022];
    networking.firewall.allowedUDPPorts = [443 2022];

    # security.acme.certs."data.r505.de" = {
    #   #server = "https://acme.zerossl.com/v2/DV90";
    #   domain = "data.r505.de";
    #   dnsProvider = "cloudflare";
    #   credentialsFile = config.age.secrets.cf-acme.path;
    #   dnsResolver = "1.1.1.1:53";
    # };

    services.sftpgo = {
      enable = true;
      group = "media";
      dataDir = "${config.chr.system.persist.stateDir}/sftpgo";
      settings = {
        common = {
          defender = {
            enabled = true;
          };
          proxy_protocol = 0;
          proxy_allowed = ["127.0.0.1" "::1"];
        };
        webdavd.bindings = mkIf cfg.webdav [
          {
            port = 8089;
            address = "/run/sftpgo/webdavd.sock";
            prefix = "/dav";
          }
        ];
        httpd.bindings = [
          {
            port = 8088;
            address = "/run/sftpgo/httpd.sock";
            hide_login_url = 3;
            branding = {
              name = "R505";
              short_name = "Cloud";
            };
          }
        ];
        sftpd = mkIf cfg.sftp {
          host_key_algorithms = [
            "rsa-sha2-512"
            "rsa-sha2-256"
            "ecdsa-sha2-nistp256"
            "ecdsa-sha2-nistp384"
            "ecdsa-sha2-nistp521"
            "ssh-ed25519"
            "ssh-rsa" # drucker
          ];
          kex_algorithms = [
            "curve25519-sha256"
            "curve25519-sha256@libssh.org"
            "ecdh-sha2-nistp256"
            "ecdh-sha2-nistp384"
            "ecdh-sha2-nistp521"
            "diffie-hellman-group14-sha256"
            "diffie-hellman-group14-sha1" # drucker
          ];
          bindings = [
            {
              port = 2022;
              address = "0.0.0.0";
            }
          ];
        };
      };
    };

    # diffie-hellman-group-exchange-sha256 diffie-hellman-group-exchange-sha1 diffie-hellman-group14-sha1

    systemd.services.sftpgo = {
      serviceConfig = {
        UMask = mkForce "007";
        RuntimeDirectory = "sftpgo";
        RuntimeDirectoryMode = "0755";
        ReadWritePaths = [cfg.userdataDir];
      };
      preStart = ''
        set -x
        ${pkgs.acl}/bin/setfacl -m group:media:rwx /mnt/userdata

        ${pkgs.acl}/bin/setfacl -m group:media:rwx /media/data-hdd/Movies
        ${pkgs.acl}/bin/setfacl -m group:media:rwx /media/data-hdd/TVShows

        set +x
      '';
      unitConfig.RequiresMountsFor = "/mnt/userdata";
    };

    services.cloudflared.tunnels."${config.networking.hostName}" = {
      ingress = {
        "data.r505.de" = "http://127.0.0.1:8033";
      };
    };

    users.users.sftpgo.extraGroups = mkIf config.chr.services.paperless.enable ["paperless"];

    services.nginx.clientMaxBodySize = "10G";

    users.users.nginx.extraGroups = ["acme" "media"];
    services.nginx.enable = true;
    services.nginx.virtualHosts."data.r505.de" = {
      listen = [
        {
          addr = "0.0.0.0";
          port = 8033;
          ssl = false;
        }
        # {
        #   addr = "unix:/var/run/nginx-data-r505.sock";
        # }
      ];
      http2 = true;
      locations = {
        "/dav/".proxyPass = "http://unix:/run/sftpgo/webdavd.sock";
        "/".proxyPass = "http://unix:/run/sftpgo/httpd.sock";
      };
    };
  };
}
