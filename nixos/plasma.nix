{
  pkgs,
  config,
  ...
}: {
  services.xserver = {
    enable = true;
    displayManager.sddm.enable = true;
    displayManager.defaultSession = "plasmawayland";
    desktopManager.plasma5 = {
      enable = true;
      runUsingSystemd = true;
    };
  };
}
