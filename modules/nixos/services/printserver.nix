{
  lib,
  config,
  flake,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (flake.lib) mkBoolOpt mkStrOpt;

  cfg = config.svc.printserver;
in
{
  options.svc.printserver = {
    enable = mkBoolOpt false;
    user = mkStrOpt "christoph";
  };
  config = mkIf cfg.enable {
    hardware.sane = {
      enable = true;
      extraBackends = [ pkgs.sane-airscan ];
      disabledDefaultBackends = [ "escl" ];
      netConf = "192.168.2.241";
    };
  };
}
