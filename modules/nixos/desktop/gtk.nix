{
  config,
  options,
  flake,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
in
{
  config = mkIf config.desktop.enable {
    home.rum.misc.gtk = {
      enable = true;
      packages = [
        # (pkgs.catppuccin-papirus-folders.override {
        #   accent = "rosewater";
        #   flavor = "mocha";
        # })
        pkgs.bibata-cursors
      ];

    };
  };
}
