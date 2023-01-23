{
  pkgs,
  config,
  ...
}: {
  services = {
    gnome = {
      core-shell.enable = true;
      core-os-services.enable = true;
      core-utilities.enable = true;
    };
    xserver = {
      displayManager.gdm.enable = true;
      desktopManager.gnome3.enable = true;
    };
  };
}
