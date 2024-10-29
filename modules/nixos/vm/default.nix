{ options
, config
, pkgs
, lib
, inputs
, ...
}:
with lib;
with lib.internal;
let
  cfg = config.internal.vm;

  hostNameToIpList = lib.imap1
    (i: v: {
      name = v;
      value = "10.0.0.${toString (i + 1)}";
    })
    cfg.vms;

  hostNameToIp = builtins.listToAttrs hostNameToIpList;

  microvm-config = {
    flake = self;
    updateFlake = "github:christoph00/nixcfg";
  };
in
{
  imports = [ ./guest.nix ];
  options.internal.vm = with types; {
    enable = mkBoolOpt false "Whether or not to configure VM config.";

    externalInterface = mkOption {
      type = types.string;
      default = "eth0";
    };

    vms = mkOption {
      type = with types; listOf string;
      default = [ ];
    };

    enableJournalLinks = mkOption {
      type = types.bool;
      default = cfg.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    microvm.host.enable = true;
    microvm.guest.enable = false;

    internal.system.state.directories = lib.mkIf config.internal.system.state.enable [
      "/var/lib/microvms"
    ];

  };

  #   config = lib.mkIf config.virtualisation.microVMs.enableJournalLinks {
  #     systemd.tmpfiles.rules = let
  #       makeJournalLink = vmName: 
  #         "L+ /var/log/journal/${config.internal.vm.vms.${vmName}.machine-id} - - - - " + 
  #         "/var/lib/microvms/${vmName}/storage/journal/${config.internal.vm.vms.${vmName}.machine-id}";
  #     in
  #       map makeJournalLink config.internal.vm.vms;
  #   };
}
