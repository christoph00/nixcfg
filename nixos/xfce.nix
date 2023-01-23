{
  config,
  pkgs,
  callPackage,
  ...
}: {
  services.xserver = {
    enable = true;
    layout = "us";
    xkbOptions = "eurosign:e";
    desktopManager.xfce = {
      enable = true;
    };
    displayManager.lightdm = {
      enable = true;
      #autoLogin.enable = true;
      #autoLogin.user = "christoph";
    };
  };
}
