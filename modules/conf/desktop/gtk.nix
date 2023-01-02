{
  pkgs,
  config,
  lib,
  ...
}: let
  css = config.scheme {
    template = builtins.readFile ./gtk.mustache;
    extension = "css";
  };
in {
  options.conf.desktop.gtk.enable = lib.mkEnableOption "gtk theme";

  config = lib.mkIf config.conf.desktop.gtk.enable {
    home-manager.users.${config.conf.users.user} = {
      gtk = {
        enable = true;
        font = lib.mkForce config.conf.fonts.sansSerif;
        theme = {
          package = pkgs.adw-gtk3;
          name = "adw-gtk3";
        };
        iconTheme = {
          name = "BeautyLine";
          package = pkgs.beauty-line-icon-theme;
        };
        cursorTheme = {
          name = "capitaine-cursors-white";
          package = pkgs.capitaine-cursors;
        };
      };

      xdg.configFile = {
        "gtk-3.0/gtk.css".source = css;
        "gtk-4.0/gtk.css".source = css;
      };
    };
  };
}
