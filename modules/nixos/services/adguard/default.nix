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
  cfg = config.internal.services.adguard;

in
{

  options.internal.services.adguard = {
    enable = mkBoolOpt config.internal.services.router.enable "Enable AdGuard.";
  };

  config = mkIf cfg.enable {
    services.adguardhome = {
      settings = {
        bind_host = "0.0.0.0";
        bind_port = 5000;
        http = {
          address = "0.0.0.0:5000";
        };
        dns = {
          bind_host = "0.0.0.0";
          bind_hosts = [ "0.0.0.0" ];
          bootstrap_dns = [
            "1.1.1.1"
            "1.0.0.1"
          ];
          upstream_dns = [
            "1.1.1.1"
            "1.0.0.1"
          ];
          enable_dnssec = true;
          ratelimit = 0;
        };
      };

    };
  };
}
