{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr;
let
  cfg = config.chr.apps.gtkcord;
in
{
  options.chr.apps.gtkcord = with types; {
    enable = mkBoolOpt config.chr.desktop.enable "Whether to enable gtkcord.";
  };

  config.chr.home.extraOptions = mkIf cfg.enable {
    home.packages = with pkgs; [ gtkcord4 ];
    xdg.enable = true;
    xdg.desktopEntries."so.libdb.gtkcord4" = {
      name = "gtkcord4";
      genericName = "Discord Chat";
      comment = "A Discord client in Go and GTK4";
      exec = "gtkcord4";
      icon = "gtkcord4";
      terminal = false;
      type = "Application";
      categories = [
        "GNOME"
        "GTK"
        "Network"
        "Chat"
      ];
      startupNotify = true;
      settings = {
        DBusActivatable = "false";
        X-GNOME-UsesNotification = "true";
        X-Purism-FormFactor = "Workstation;Mobile;";
      };
    };
  };
}
