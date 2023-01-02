{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.conf.fonts;

  fontType = types.submodule {
    options = {
      package = mkOption {
        description = "Package providing the font.";
        type = types.package;
      };

      name = mkOption {
        description = "Name of the font within the package.";
        type = types.str;
      };
    };
  };
in {
  options.conf.fonts.enable = mkEnableOption "Enable Fonts";

  options.conf.fonts = {
    serif = mkOption {
      description = "Serif font.";
      type = fontType;
      default = {
        package = pkgs.roboto-slab;
        name = "Roboto Slab";
      };
    };

    sansSerif = mkOption {
      description = "Sans-serif font.";
      type = fontType;
      default = {
        package = pkgs.roboto;
        name = "Roboto";
      };
    };

    monospace = mkOption {
      description = "Monospace font.";
      type = fontType;
      default = {
        package = pkgs.nerdfonts.override {fonts = ["Agave"];};
        name = "Agave Nerd Font";
      };
    };

    emoji = mkOption {
      description = "Emoji font.";
      type = fontType;
      default = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    fonts = {
      fonts = [
        cfg.monospace.package
        cfg.serif.package
        cfg.sansSerif.package
        cfg.emoji.package
      ];
      fontconfig.defaultFonts = {
        monospace = [cfg.monospace.name];
        serif = [cfg.serif.name];
        sansSerif = [cfg.sansSerif.name];
        emoji = [cfg.emoji.name];
      };
    };
    home-manager.users.${config.conf.users.user} = {
      gtk.enable = true;
      gtk.font = {
        package = cfg.sansSerif.package;
        name = cfg.sansSerif.name;
      };
    };
  };
}
