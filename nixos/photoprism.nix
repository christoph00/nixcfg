{
  config,
  lib,
  ...
}: {
  services.photoprism = {
    enable = true;
    address = "0.0.0.0";
    originalsPath = "/mnt/userdata/photos";
    #importPath = "/mnt/userdata/photos";
    settings = {
      PHOTOPRISM_DEFAULT_LOCALE = "de";
      PHOTOPRISM_DISABLE_PLACES = "false";
      PHOTOPRISM_DISABLE_TENSORFLOW = "true";
      PHOTOPRISM_EXPERIMENTAL = "true";
      PHOTOPRISM_JPEG_QUALITY = "92";
      PHOTOPRISM_ORIGINALS_LIMIT = "10000";
      PHOTOPRISM_ADMIN_PASSWORD = "start001";
      PHOTOPRISM_DISABLE_CLASSIFICATION = "true";
      PHOTOPRISM_DISABLE_RAW = "true";
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
