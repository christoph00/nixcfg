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
  internal.system.boot.enable = false;
  internal.system.fs.enable = false;

  raspberry-pi-nix.board = "bcm2711";


  nixpkgs.hostPlatform =  "aarch64-linux";

  system.stateVersion = "24.05";
}
