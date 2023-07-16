{config, ...}: {
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
      "/".proxyPass = "http://127.0.0.1:4001";
    };
  };

  virtualisation.oci-containers.containers.photoview = {
    ports = ["0.0.0.0:4001:4001"];
    image = "viktorstrate/photoview:2";
    user = "994:256";
    environment = {
      PHOTOVIEW_DATABASE_DRIVER = "sqlite";
      PHOTOVIEW_SQLITE_PATH = "/app/db/database.db";
      PHOTOVIEW_LISTEN_IP = "0.0.0.0";
      PHOTOVIEW_LISTEN_PORT = "4001";
      PHOTOVIEW_MEDIA_CACHE = "/app/cache";
      PHOTOVIEW_DISABLE_RAW_PROCESSING = "1";
      PHOTOVIEW_DISABLE_VIDEO_ENCODING = "1";
    };
    volumes = [
      "/nix/persist/sftpgo/photoview/db:/app/db"
      "/nix/persist/sftpgo/photoview/cache:/app/cache"
      "/mnt/userdata/christoph/Bilder:/photos/christoph:ro"
    ];
    cmd = ["run" "server"];
  };
}
