{
  options,
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
with lib.internal;
let
  cfg = config.internal.vm;

  hostNameToIpList = lib.imap1 (i: v: {
    name = v;
    value = "10.0.0.${toString (i + 1)}";
  }) cfg.vms;

  hostNameToIp = builtins.listToAttrs hostNameToIpList;
in
{
  options.internal.vm = with types; {
    enable = mkBoolOpt false "Whether or not to configure VM config.";
    isGuest = mkBoolOpt' false;

    externalInterface = mkOption {
      type = types.string;
      default = "eth0";
    };

    vms = mkOption {
      type = with types; listOf string;
      default = [ ];
    };
  };

  config = mkIf cfg.enable {


  };
}
