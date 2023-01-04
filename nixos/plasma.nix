{
  pkgs,
  config,
  ...
}: {
  programs.gnupg.agent.pinentryFlavor = "qt";

  services.gnome.gnome-keyring.enable = true;

  services.xserver = {
    enable = true;
    displayManager.sddm.enable = true;
    displayManager.defaultSession = "plasmawayland";
    desktopManager.plasma5 = {
      enable = true;
      runUsingSystemd = true;
    };
  };

  programs.kdeconnect.enable = true;
}
