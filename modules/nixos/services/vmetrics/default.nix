# https://github.com/hbjydev/dots.nix
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.vmetrics;
in {
  options = {
    services.vmetrics = {
      enable = mkEnableOpt' false;
    };
  };

  config = mkIf cfg.enable {
    services.victoriametrics = {
      enable = true;
      listenAddress = ":8428";
      retentionPeriod = 2;
    };
  };
}
