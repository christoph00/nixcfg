{
  config,
  pkgs,
  lib,
  ...
}: {
  environment.persistence."/nix/persist" = {
    directories = [
      {
        directory = "/var/lib/syncthing";
        inherit (config.services.syncthing) user group;
      }
    ];
  };
  services.syncthing = {
    enable = true;
    guiAddress = "0.0.0.0:8384";
    group = "media";
    user = "christoph";
  };
}
