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
      }
    ];
  };
  services.syncthing = {
    enable = true;
    guiAddress = "0.0.0.0:8384";
    user = "christoph";
  };
}
