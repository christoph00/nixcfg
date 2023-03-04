{
  pkgs,
  lib,
  ...
}: {
  services.stalwart = {
    enable = true;
    jmap = {
      enable = true;
      settings = {
        jmap-url = "https://jmap.r505.de";
        jmap-port = 8033;
      };
    };
  };
}
