{
  options,
  config,
  pkgs,
  lib,
  inputs,
  flake,
  ...
}:
let
  inherit (lib) mkIf mkForce;
  inherit (lib.types) string listOf;
  inherit (flake.lib) mkOpt mkBoolOpt mkStrOpt;
  cfg = config.virt.microvm;

  hostNameToIpList = lib.imap1 (i: v: {
    name = v;
    value = "10.5.5.${toString (i + 1)}";
  }) cfg.vms;

  hostNameToIp = builtins.listToAttrs hostNameToIpList;

  microvm-config = {
    inherit flake;
    updateFlake = "github:christoph00/nixcfg";
  };
in
{
  imports = [
    inputs.microvm.nixosModules.host
    inputs.microvm.nixosModules.microvm
    ./guest.nix
  ];
  options.virt.microvm = {
    enable = mkBoolOpt false;
    isGuest = mkBoolOpt false;

    externalInterface = mkStrOpt "eth0";

    vms = mkOpt (listOf string) [ ];

    enableJournalLinks = mkBoolOpt false;
  };

  config = {
    microvm.host.enable = mkForce cfg.enable;

    sys.state.directories = mkIf cfg.enable [
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
