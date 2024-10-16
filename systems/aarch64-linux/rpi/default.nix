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
  imports = [  inputs.raspberry-pi-nix.nixosModules.raspberry-pi];

  networking.hostName = "rpi";

  internal.type = "server";
  internal.system.fs.enable = false;

  raspberry-pi-nix.board = "bcm2711";


  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  system.stateVersion = "24.05";
}
