{
  lib,
  flake,
  pkgs,
  config,
  options,
  ...
}:
let
  inherit (lib) mkIf attrValues;
  inherit (flake.lib) mkBoolOpt;
  cfg = config.desktop;
in
{
  config = mkIf cfg.enable {
    fonts.packages = lib.attrValues {
      inherit (pkgs)
        corefonts

        source-sans
        source-serif

        dejavu_fonts
        inter

        noto-fonts

        noto-fonts-cjk-sans
        noto-fonts-cjk-serif

        noto-fonts-color-emoji
        material-icons
        material-design-icons
        ;

      inherit (pkgs.nerd-fonts)
        symbols-only
        bigblue-terminal
        agave
        blex-mono
        ;
    };
  };

}
