{
  config,
  pkgs,
  lib,
  ...
}:
with lib; {
  config = mkIf (builtins.elem config.nos.type ["desktop" "laptop"]) {
    fonts = {
      enableDefaultPackages = false;

      fontconfig = {
        # this fixes emoji stuff
        enable = true;

        defaultFonts = {
          monospace = [
            "Iosevka Term"
            "Iosevka Term Nerd Font Complete Mono"
            "Iosevka Nerd Font"
            "Noto Color Emoji"
          ];
          sansSerif = ["Lexend" "Noto Color Emoji"];
          serif = ["Noto Serif" "Noto Color Emoji"];
          emoji = ["Noto Color Emoji"];
        };
      };

      fontDir = {
        enable = true;
        decompressFonts = true;
      };

      # font packages that should be installed
      packages = with pkgs; [
        corefonts
        material-icons
        material-design-icons
        roboto
        work-sans
        comic-neue
        source-sans
        twemoji-color-font
        comfortaa
        inter
        lato
        jost
        lexend
        dejavu_fonts
        iosevka-bin
        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji
        emacs-all-the-icons-fonts

        (nerdfonts.override {fonts = ["Iosevka" "JetBrainsMono" "FiraCode" "Agave"];})
      ];
    };
  };
}
