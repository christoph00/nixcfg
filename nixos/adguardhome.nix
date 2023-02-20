{
  pkgs,
  config,
  lib,
  ...
}: {
  services.adguardhome = {
    enable = true;
    openFirewall = true;
  };
}
