{
  config,
  pkgs,
  lib,
  ...
}: {
  networking.firewall.allowedTCPPorts = [80 443];
  networking.firewall.allowedUDPPorts = [443];

  services.sftpgo = {
    enable = true;
    group = "media";
    dataDir = "/nix/persist/sftpgo";
    settings = {
      common = {
        defender = {
          enabled = true;
        };
        proxy_protocol = 0;
        proxy_allowed = ["127.0.0.1" "::1"];
      };
      webdavd.bindings = [
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
      sftpd.bindings = [
        {
          port = 2022;
          address = "0.0.0.0";
        }
      ];
    };
  };
  systemd.services.sftpgo.serviceConfig.RuntimeDirectory = "sftpgo";
  systemd.services.sftpgo.serviceConfig.RuntimeDirectoryMode = "0755";
  systemd.services.sftpgo.serviceConfig.UMask = lib.mkForce "007";

  services.nginx.clientMaxBodySize = "10G";

  users.users.nginx.extraGroups = ["acme" "media"];
  services.nginx.enable = true;
  services.nginx.virtualHosts."data.r505.de" = {
    http2 = true;
    forceSSL = true;
    useACMEHost = "r505.de";
    locations = {
      "/dav/".proxyPass = "http://unix:/run/sftpgo/webdavd.sock";
      "/".proxyPass = "http://unix:/run/sftpgo/httpd.sock";
    };
  };
}
