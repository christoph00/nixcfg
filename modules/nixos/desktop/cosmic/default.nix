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
    xdg.portal.enable = true;
    xdg.portal.extraPortals = [inputs.xdg-desktop-portal-cosmic.packages.${system}.default];

    environment.systemPackages = with inputs; [
      cosmic-applets.packages.${system}.default
      cosmic-applibrary.packages.${system}.default
      cosmic-bg.packages.${system}.default
      cosmic-comp.packages.${system}.default
      cosmic-launcher.packages.${system}.default
      cosmic-osd.packages.${system}.default
      cosmic-panel.packages.${system}.default
      cosmic-settings.packages.${system}.default
      cosmic-settings-daemon.packages.${system}.default
    ];
  };
}
