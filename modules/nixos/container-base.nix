{ config, lib, pkgs, flake, inputs, ... }: let
  inherit (flake.lib) mkBoolOpt;
in {
  imports = [
    # Eigene Module — Services, Netzwerk, Secrets, System
    flake.modules.nixos.services
    flake.modules.nixos.network
    flake.modules.nixos.secrets
    flake.modules.nixos.system
    flake.modules.nixos.virt
  ];

  # host-Optionen — einige Service-Module referenzieren config.host.*
  options.host = {
    graphical = mkBoolOpt false;
    gaming = mkBoolOpt false;
    vm = mkBoolOpt false;
    server = mkBoolOpt false;
    minimal = mkBoolOpt false;
  };

  # === Container-Optimierung ===
  config.boot.isContainer = true;

  # nix deaktivieren — Store ist read-only vom Host
  config.nix.enable = false;
  config.nix.gc = lib.mkForce { automatic = false; };
  config.nix.optimise = lib.mkForce { automatic = false; };
  config.programs.nh.enable = lib.mkForce false;
  config.programs.nh.clean.enable = lib.mkForce false;
  config.system.disableInstallerTools = lib.mkForce true;

  # DNS kommt vom Host — resolved im Container aus
  config.services.resolved.enable = false;

  config.services.openssh.enable = true;
  config.users.users.root.initialHashedPassword = "";

  # Container-unsafe Subsysteme deaktivieren
  config.sys.boot.enable = lib.mkForce false;
  config.sys.kernel.enable = lib.mkForce false;
  config.sys.disk.enable = lib.mkForce false;
  config.sys.state.enable = lib.mkForce false;
  config.sys.console = false;

  # Bootloader
  config.boot.loader.grub.enable = lib.mkForce false;
  config.boot.loader.systemd-boot.enable = lib.mkForce false;

  # Keine Firmware
  config.hardware.enableRedistributableFirmware = lib.mkDefault false;

  config.system.stateVersion = "25.11";
}
