{
  config,
  pkgs,
  ...
}: {
  networking.firewall.allowedTCPPorts = [80 443];
  networking.firewall.allowedUDPPorts = [443];

  services.sftpgo = {
    enable = true;
    group = "media";
    dataDir = "/mnt/ncdata";
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
          port = 0;
          address = "/run/sftpgo/webdavd.sock";
          prefix = "/dav";
        }
      ];
      httpd.bindings = [
        {
          port = 0;
          address = "/run/sftpgo/httpd.sock";
          hide_login_url = 3;
          branding = {
            name = "R505";
            short_name = "Cloud";
          };
        }
      ];
    };
  };

  services.caddy.virtualHosts."cloud.r505.de" = {
    useACMEHost = "r505.de";
    extraConfig = ''
      reverse_proxy unix/run/sftpgo/httpd.sock
      encode gzip zstd
      route /dav/* {
        reverse_proxy unix/run/sftpgo/webdavd.sock
      }
    '';
  };
}
