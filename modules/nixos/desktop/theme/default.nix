{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.desktop.theme;
in {
  options.chr.desktop.theme = with types; {
    enable = mkBoolOpt' config.chr.desktop.enable;
  };

  config = mkIf cfg.enable {
    chr.home.extraOptions = {
      fonts.fontconfig.enable = true;
      gtk = {
        enable = true;
        #font = {
        #  name = fontProfiles.regular.family;
        #  size = 12;
        #};
        theme = {
          #   #name = "${config.colorscheme.slug}";
          #   #package = gtkThemeFromScheme {scheme = config.colorscheme;};
          name = "Tokyo-Night";
          package = pkgs.tokyo-night-gtk;
        };
        iconTheme = {
          name = "Fluent";
          package = pkgs.fluent-icon-theme;
        };
        cursorTheme = {
          name = "macOS-Monterey";
          package = pkgs.apple-cursor;
          #size = builtins.ceil (16 * primaryMonitor.scale);
          size = 16;
        };
        # gtk3.extraCss = ''
        #   button.image-button {
        #     border-radius: 1px;
        #   };
        # '';
      };

      services.xsettingsd = {
        enable = true;
        settings = {
          "Net/ThemeName" = "${config.gtk.theme.name}";
          "Net/IconThemeName" = "${config.gtk.iconTheme.name}";
        };
      };
    };
  };
}
