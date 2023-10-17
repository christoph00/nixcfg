{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.desktop.fonts;
  mkFontOption = kind: {
    family = lib.mkOption {
      type = lib.types.str;
      default = "Fira Code";
      description = "Family name for ${kind} font profile";
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.fira-code;
      description = "Package for ${kind} font profile";
    };
  };
in {
  options.chr.desktop.fonts = with types; {
    enable =
      mkBoolOpt config.chr.desktop.enable "Enable Font Config";
    fontProfiles = {
      monospace = mkFontOption "monospace";
      regular = mkFontOption "regular";
    };
  };

  config = mkIf cfg.enable {
    fonts = {
      fontDir.enable = true;
      packages = with pkgs; [
        chr.san-francisco-pro
        jetbrains-mono

        # Icons
        material-design-icons
        noto-fonts-emoji

        material-symbols
        lexend
        noto-fonts
        noto-fonts-emoji
        roboto
        (nerdfonts.override {fonts = ["FiraCode" "JetBrainsMono" "Iosevka"];})
      ];

      enableDefaultPackages = false;
      fontconfig = {
        enable = true;
        defaultFonts = {
          serif = ["Roboto Serif" "Noto Color Emoji"];
          sansSerif = ["Roboto" "Noto Color Emoji"];
          monospace = ["JetBrainsMono Nerd Font" "Noto Color Emoji"];
          emoji = ["Noto Color Emoji"];
        };
      };
    };
  };
}
