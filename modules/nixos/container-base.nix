{ config, lib, pkgs, flake, inputs, modulesPath, ... }: let
  inherit (flake.lib) mkBoolOpt;
in {
  imports = [
    "${modulesPath}/profiles/perlless.nix"

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

  # === Container-Guestsystem ===
  config.boot.isContainer = true;

  # Store ist read-only — kein nix-daemon im Container
  config.nix.enable = false;
  config.nix.gc = lib.mkForce { automatic = false; };
  config.nix.optimise = lib.mkForce { automatic = false; };
  config.programs.nh.enable = lib.mkForce false;
  config.programs.nh.clean.enable = lib.mkForce false;
  config.system.disableInstallerTools = lib.mkForce true;

  # resolved + useHostResolvConf = kein Konflikt (resolved aus)
  config.services.resolved.enable = lib.mkForce false;

  # nspawn setzt IP via localAddress — kein DHCP nötig
  config.systemd.network.enable = lib.mkForce false;

  # SSH für machinectl shell
  config.services.openssh.enable = true;
  config.users.users.root.initialHashedPassword = "";

  # Container-unsafe Module deaktivieren
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
