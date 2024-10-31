{
  config,
  lib,
  pkgs,
  modulesPath,
  inputs,
  namespace,
  ...
}:
{
  imports = [
    (modulesPath + "/virtualisation/qemu-vm.nix")
    inputs.microvm.nixosModules.microvm
  ];

  networking.hostName = "vm-smarthome";

  internal.type = "microvm";

  system.stateVersion = "24.05";
}
