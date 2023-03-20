{...}: {
  programs.xfconf.enable = true;
  services.xserver = {
    enable = true;
    layout = "us";
    xkbOptions = "eurosign:e";
    desktopManager.xfce = {
      enable = true;
    };
  };
}
