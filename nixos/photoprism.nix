{
  config,
  lib,
  ...
}: {
  security.acme.certs."fotos.r505.de" = {
    #server = "https://acme.zerossl.com/v2/DV90";
    domain = "fotos.r505.de";
    dnsProvider = "cloudflare";
    credentialsFile = config.age.secrets.cf-acme.path;
    dnsResolver = "1.1.1.1:53";
  };

  users.users.nginx.extraGroups = ["acme" "media"];
  services.nginx.enable = true;
  services.nginx.virtualHosts."fotos.r505.de" = {
    http2 = true;
    forceSSL = true;
    useACMEHost = "fotos.r505.de";
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:2342";
        proxyWebsockets = true;
      };
    };
  };

  services.photoprism = {
    enable = true;
    address = "0.0.0.0";
    originalsPath = "/mnt/userdata/photos";
    #importPath = "/mnt/userdata/photos";
    settings = {
      PHOTOPRISM_DEFAULT_LOCALE = "de";
      PHOTOPRISM_USERS_PATH = "/mnt/userdata/photos/users";
      PHOTOPRISM_SIDECAR_PATH = "/mnt/userdata/photos/sidecar";
      PHOTOPRISM_CACHE_PATH= "/mnt/userdata/photos/cache";
      PHOTOPRISM_DISABLE_PLACES = "false";
      PHOTOPRISM_DISABLE_TENSORFLOW = "true";
      PHOTOPRISM_EXPERIMENTAL = "true";
      PHOTOPRISM_JPEG_QUALITY = "92";
      PHOTOPRISM_ORIGINALS_LIMIT = "10000";
      PHOTOPRISM_ADMIN_PASSWORD = "start001";
      PHOTOPRISM_DISABLE_CLASSIFICATION = "false";
      PHOTOPRISM_DISABLE_RAW = "true";
      PHOTOPRISM_DISABLE_FACES = "false";
      PHOTOPRISM_SITE_CAPTION = "Fotos";
      PHOTOPRISM_HTTP_COMPRESSION = "gzip";
      PHOTOPRISM_SETTINGS_HIDDEN = "false";
      PHOTOPRISM_SPONSOR = "true";
    };
  };

  environment.persistence = {
    "/nix/persist".directories = ["/var/lib/photoprism"];
  };

  systemd.services.photoprism.serviceConfig = {
    User = lib.mkForce "sftpgo";
    Group = lib.mkForce "sftpgo";
    DynamicUser = lib.mkForce false;
  };

  networking.firewall.allowedTCPPorts = [2342];
}
