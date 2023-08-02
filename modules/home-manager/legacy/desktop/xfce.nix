{
  config,
  pkgs,
  ...
}: {
  xfconf.settings = {
    xfce4-session = {
      "startup/ssh-agent/enabled" = false;
      "general/LockCommand" = "${pkgs.lightdm}/bin/dm-tool lock";
    };
    xfce4-desktop = {
      "backdrop/screen0/monitorLVDS-1/workspace0/last-image" = "${config.wallpaper}";
    };
  };
  home.persistence = {
    "/nix/persist/home/christoph".directories = [".config/xfce4"];
  };
}
