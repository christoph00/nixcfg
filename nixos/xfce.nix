{
  config,
  pkgs,
  callPackage,
  ...
}: {
  services.xserver = {
    enable = true;
    desktopManager = {
      xfce.enable = true;
    };
  };
}
