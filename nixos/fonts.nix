{
  config,
  lib,
  pkgs,
  ...
}: {
  fonts.fonts = with pkgs; [
    corefonts
    fira
    inter
    lato
    league-of-moveable-type
    libertine
    (nerdfonts.override {fonts = ["Agave" "FiraCode"];})
    twitter-color-emoji
    yanone-kaffeesatz
    inriafonts

    material-icons
  ];

  # fonts.fontconfig.defaultFonts = lib.mkDefault {
  #   serif = ["Linux Libertine"];
  #   sansSerif = ["Inter"];
  #   monospace = ["Iosevka Term"];
  #   emoji = ["Twitter Color Emoji"];
  # };
}
