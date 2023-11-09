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
  imports = [
    inputs.cosmic-desktop.nixosModules.default
  ];
  options.chr.desktop.cosmic = with types; {
    enable = mkBoolOpt false "Whether or not to enable Cosmic Desktop.";
  };

  config = mkIf cfg.enable {
    services.xserver.desktopManager.cosmic.enable = true;
  };
}
