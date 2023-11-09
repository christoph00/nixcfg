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
    xdg.portal.extraPortals = [inputs.xdg-desktop-portal-cosmic.packages.${pkgs.system}.default];

    environment.systemPackages = with inputs; [
      cosmic-applets.packages.${pkgs.system}.default
      cosmic-applibrary.packages.${pkgs.system}.default
      cosmic-bg.packages.${pkgs.system}.default
      cosmic-comp.packages.${pkgs.system}.default
      cosmic-launcher.packages.${pkgs.system}.default
      cosmic-osd.packages.${pkgs.system}.default
      cosmic-panel.packages.${pkgs.system}.default
      cosmic-settings.packages.${pkgs.system}.default
      # cosmic-settings-daemon.packages.${pks.system}.default
    ];
  };
}
