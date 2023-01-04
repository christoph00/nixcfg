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

  security.pam.services = {
    sddm.u2fAuth = false;
    sddm.enableGnomeKeyring = true;
  };

  programs.kdeconnect.enable = true;
}
