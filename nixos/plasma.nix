{
  pkgs,
  config,
  ...
}: {
  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    displayManager.defaultSession = "plasmawayland";
    desktopManager.plasma5 = {
      enable = true;
      runUsingSystemd = true;
    };
  };
}
