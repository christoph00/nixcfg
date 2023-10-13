{
  config,
  lib,
  pkgs,
  modulesPath,
  inputs,
  ...
}:
with lib;
with lib.chr; let
  inherit (inputs) nixos-hardware;
in {
  imports = with nixos-hardware.nixosModules; [
    (modulesPath + "/installer/scan/not-detected.nix")
    common-pc
    common-pc-ssd
  ];
  networking.hostName = "oc2";

  chr = {
    type = "server";
    system.filesystem = {
      enable = true;
      persist = false;
      rootOnTmpfs = false;
    };
  };



  system.stateVersion = "23.11";
}
