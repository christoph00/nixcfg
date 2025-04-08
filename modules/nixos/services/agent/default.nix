{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib,
  # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs,
  # You also have access to your flake's inputs.
  inputs,
  # Additional metadata is provided by Snowfall Lib.
  namespace,
  # The namespace used for your flake, defaulting to "internal" if not set.
  system,
  # The system architecture for this host (eg. `x86_64-linux`).
  target,
  # The Snowfall Lib target for this system (eg. `x86_64-iso`).
  format,
  # A normalized name for the system target (eg. `iso`).
  virtual,
  # A boolean to determine whether this system is a virtual target using nixos-generators.
  systems, # An attribute map of your defined hosts.

  # All other arguments come from the module system.
  config,
  ...
}:

with builtins;
with lib;
with lib.internal;

let
  cfg = config.internal.services.agent;

in
{

  options.internal.services.agent = {
    enable = mkBoolOpt true "Enable Agent.";

  };

  config = mkIf cfg.enable {

    users.users.agent = {
      isSystemUser = true;
      group = "agent";
      home = "/var/lib/agent";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHaBH8zJjpPUMN4By4fZLXHSSiZ05nLcA3PrUsvczhd9"
      ];
    };
    users.groups.agent = { };

    security.doas.extraRules = [
      {
        users = [ "agent" ];
        cmd = "systemctl";
        args = [
          "status"
          "stop"
          "start"
          "restart"
          "reboot"
        ];
        runAs = "root";
        noPass = true;
      }

      {
        users = [ "agent" ];
        cmd = "nh";
        noPass = true;
        runAs = "root";
      }
    ];

  };
}
