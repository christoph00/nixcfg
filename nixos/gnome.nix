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
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };
  };
}
