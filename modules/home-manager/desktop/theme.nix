{
  inputs,
  inputs',
  pkgs,
  osConfig,
  config,
  lib,
  ...
}: let
  inherit (inputs.nix-colors.lib-contrib {inherit pkgs;}) gtkThemeFromScheme;
  fontProfiles = osConfig.nos.desktop.fontProfiles;
in {
  config = lib.mkIf (builtins.elem osConfig.nos.type ["desktop" "laptop"]) {
    colorscheme = inputs.nix-colors.colorSchemes.tokyo-city-terminal-light;

    gtk = {
      enable = true;
      font = {
        name = fontProfiles.regular.family;
        size = 12;
      };
      theme = {
        #name = "${config.colorscheme.slug}";
        #package = gtkThemeFromScheme {scheme = config.colorscheme;};
        name = "Fluent-Light";
        package = pkgs.fluent-gtk-theme;
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

    fonts.fontconfig.enable = true;
    home.packages = [fontProfiles.monospace.package fontProfiles.regular.package];

    services.xsettingsd = {
      enable = true;
      settings = {
        "Net/ThemeName" = "${config.gtk.theme.name}";
        "Net/IconThemeName" = "${config.gtk.iconTheme.name}";
      };
    };
  };
}
