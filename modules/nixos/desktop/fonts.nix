{
  lib,
  flake,
  pkgs,
  config,
  perSystem,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.desktop;
  up = perSystem.nixpkgs-unstable;
in
{
  config = mkIf cfg.enable {
    fonts.packages = (with up; [
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
      dina-font
      aporetic
      monaspace
      victor-mono
      gohufont
      maple-mono.truetype
    ]) ++ (with up.nerd-fonts; [
      symbols-only
      bigblue-terminal
      agave
      blex-mono
    ]);
  };
}
