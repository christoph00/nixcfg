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
    # font = {
    #   name = config.fontProfiles.regular.family;
    #   size = 12;
    # };
    theme = {
      name = "${config.colorscheme.slug}";
      package = gtkThemeFromScheme {scheme = config.colorscheme;};
      #name = "Fluent-Light";
      #package = pkgs.fluent-gtk-theme;
    };
    iconTheme = {
      name = "Fluent";
      package = pkgs.fluent-icon-theme;
    };
    cursorTheme = {
      name = "macOS-Monterey";
      package = pkgs.apple-cursor;
      size = 16;
    };
    gtk3.extraCss = ''
      button.image-button {
        border-radius: 1px;
      };
    '';
  };

  services.xsettingsd = {
    enable = true;
    settings = {
      "Net/ThemeName" = "${config.gtk.theme.name}";
      "Net/IconThemeName" = "${config.gtk.iconTheme.name}";
    };
  };
}
