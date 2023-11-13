{
  options,
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.desktop.ags;
in {
  options.chr.desktop.ags = with types; {
    enable = mkBoolOpt config.chr.hyprland.enable "Whether or not enable Ags.";
  };

  config = mkIf cfg.enable {
    chr.home.extraOptions = {
      home.packages = [
        inputs.ags.packages.${pkgs.system}.default
      ];
    };
  };
}
