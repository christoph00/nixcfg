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
        # Icons
        material-design-icons
        material-symbols

        noto-fonts-emoji
        liberation_ttf
        lexend
        noto-fonts
        dejavu_fonts
        ubuntu_font_family
        unifont
        roboto
        (nerdfonts.override {fonts = ["FiraCode" "JetBrainsMono" "Iosevka" "Agave" "IBMPlexMono" "Gohu" "Hermit" "IntelOneMono" "ComicShannsMono" "DaddyTimeMono"];})
        chr.operator-mono-nf
        #intel-one-mono
        monaspace
      ];

      #   enableDefaultPackages = false;
      fontconfig = {
        enable = true;
        defaultFonts = {
          serif = ["Lexend" "Noto Color Emoji"];
          sansSerif = ["Lexend" "Noto Color Emoji"];
          monospace = ["JetBrainsMono Nerd Font" "Noto Color Emoji"];
          emoji = ["Noto Color Emoji"];
        };
      };
    };
  };
}
