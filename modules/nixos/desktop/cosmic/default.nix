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
  options.chr.desktop.plasma = with types; {
    enable = mkBoolOpt config.chr.desktop.enable "Whether or not to enable Cosmic Desktop.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      inputs.cosmic-session.packages.x86_64-linux.default
      inputs.cosmic-comp.packages.x86_64-linux.default
      inputs.cosmic-panel.packages.x86_64-linux.default
      inputs.cosmic-applibrary.packages.x86_64-linux.default
      inputs.cosmic-launcher.packages.x86_64-linux.default
      inputs.cosmic-settings.packages.x86_64-linux.default
      inputs.cosmic-applets.packages.x86_64-linux.default
      # inputs.cosmic-notifications.packages.x86_64-linux.default
      inputs.cosmic-osd.packages.x86_64-linux.default
      inputs.cosmic-workspaces.packages.x86_64-linux.default
      inputs.cosmic-bg.packages.x86_64-linux.default
      inputs.xdg-desktop-portal-cosmic.packages.x86_64-linux.default
      inputs.cosmic-settings-daemon.packages.x86_64-linux.default
    ];
  };
}
