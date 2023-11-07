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
  cfg = config.chr.desktop.cosmic;
in {
  options.chr.desktop.cosmic = with types; {
    enable = mkBoolOpt config.chr.desktop.enable "Whether or not to enable Cosmic Desktop.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      cosmic-comp
      cosmic-panel
      cosmic-icons
      cosmic-applets
      cosmic-settings
    ];
  };
}
