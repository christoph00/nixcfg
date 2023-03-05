{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = [pkgs.vmt pkgs.vomit-sync];
  services.stalwart = {
    enable = true;
    jmap = {
      enable = true;
      settings = {
        jmap-url = "https://jmap.r505.de";
        jmap-port = 8055;
      };
    };
  };
}
