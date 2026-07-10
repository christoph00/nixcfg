{ config, lib, pkgs, flake, inputs, modulesPath, ... }: let
  inherit (flake.lib) mkBoolOpt;
in {
  imports = [
    flake.modules.nixos.services
    flake.modules.nixos.network
    flake.modules.nixos.secrets
    flake.modules.nixos.system
    flake.modules.nixos.virt
  ];

  options.host = {
    graphical = mkBoolOpt false;
    gaming = mkBoolOpt false;
    vm = mkBoolOpt false;
    server = mkBoolOpt false;
    minimal = mkBoolOpt false;
  };

  config.boot.isContainer = true;

  config.nix.enable = false;
  config.nix.gc = lib.mkForce { automatic = false; };
  config.nix.optimise = lib.mkForce { automatic = false; };
  config.programs.nh.enable = lib.mkForce false;
  config.programs.nh.clean.enable = lib.mkForce false;
  config.system.disableInstallerTools = lib.mkForce true;

  config.services.resolved.enable = lib.mkForce false;

  config.systemd.network.enable = lib.mkForce false;

  config.services.openssh.enable = true;
  config.users.users.root.initialHashedPassword = "";

  config.sys.boot.enable = lib.mkForce false;
  config.sys.kernel.enable = lib.mkForce false;
  config.sys.disk.enable = lib.mkForce false;
  config.sys.state.enable = lib.mkForce false;
  config.sys.console = false;

  config.boot.loader.grub.enable = lib.mkForce false;
  config.boot.loader.systemd-boot.enable = lib.mkForce false;
  config.hardware.enableRedistributableFirmware = lib.mkDefault false;

  config.system.stateVersion = "25.11";
}
