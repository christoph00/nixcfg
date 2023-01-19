{
  config,
  pkgs,
  inputs,
  ...
}: let
  inherit (inputs.nix-colors.lib-contrib {inherit pkgs;}) gtkThemeFromScheme;
in {
  gtk = {
    enable = true;
    font = {
      name = config.fontProfiles.regular.family;
      size = 12;
    };
    theme = {
      name = "${config.colorscheme.slug}";
      package = gtkThemeFromScheme {scheme = config.colorscheme;};
    };
    #iconTheme = {
    #  name = "Papirus";
    #  package = pkgs.papirus-icon-theme;
    #};
    iconTheme = {
      name = "WhiteSur-dark";
      package = pkgs.whitesur-icon-theme;
    };
    cursorTheme = {
      name = "macOS-Monterey";
      package = pkgs.apple-cursor;
      #size = 16;
    };
  };

  services.xsettingsd = {
    enable = true;
    settings = {
      "Net/ThemeName" = "${config.gtk.theme.name}";
      "Net/IconThemeName" = "${config.gtk.iconTheme.name}";
    };
  };
}
