{
  config,
  lib,
  flake,
  options,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (flake.lib) mkBoolOpt;
  cfg = config.desktop;
in
{
  imports = [ inputs.cosmic.nixosModules.default ];
  options.desktop.cosmic = mkBoolOpt false;
  config = mkIf cfg.cosmic {

    services.desktopManager.cosmic.enable = true;

    environment.cosmic.excludePackages = [
      pkgs.cosmic-edit
      pkgs.cosmic-term
      pkgs.cosmic-store
    ];

  };
}
