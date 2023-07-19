{config, ...}: {
  services.photoprism = {
    enable = true;
    address = "[::]";
    originalsPath = "/mnt/userdata/photos";
    importPath = "/mnt/userdata/photos";
    storagePath = "/nix/persist/photoprism";
    settings = {
      PHOTOPRISM_DEFAULT_LOCALE = "de";
      PHOTOPRISM_DISABLE_PLACES = "false";
      PHOTOPRISM_DISABLE_TENSORFLOW = "true";
      PHOTOPRISM_EXPERIMENTAL = "true";
      PHOTOPRISM_JPEG_QUALITY = "92";
      PHOTOPRISM_ORIGINALS_LIMIT = "10000";
    };
  };

  networking.firewall.allowedTCPPorts = [2342];
}
