{
  pkgs,
  config,
  lib,
  ...
}: {
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_14;
  };

  services.postgresqlBackup = {
    enable = true;
    compression = "zstd";
  };

  security.acme.certs."pub.r505.de" = {
    #server = "https://acme.zerossl.com/v2/DV90";
    domain = "pub.r505.de";
    dnsProvider = "cloudflare";
    credentialsFile = config.age.secrets.cf-acme.path;
    dnsResolver = "1.1.1.1:53";
  };

  services.nginx.virtualHosts."pub.r505.de" = {
    http2 = true;
    forceSSL = true;
    useACMEHost = "pub.r505.de";
  };
  users.users.nginx.extraGroups = ["acme"];

  services.lemmy = {
    enable = true;
    nginx.enable = true;

    settings = {
      hostname = "pub.r505.de";
      database = {
        user = "lemmy";
        host = "/run/postgresql";
        port = 5432;
        database = "lemmy";
        pool_size = 5;
      };
    };
  };

  services.postgresql = {
    ensureDatabases = ["lemmy"];
    ensureUsers = [
      {
        name = "lemmy";
        ensurePermissions = {
          "DATABASE \"lemmy\"" = "ALL PRIVILEGES";
        };
      }
    ];
  };
}
