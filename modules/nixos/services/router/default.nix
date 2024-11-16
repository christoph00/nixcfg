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
  cfg = config.internal.services.router;

in

{

  options.internal.services.router = {
    enable = mkBoolOpt config.internal.isRouter "Enable Router.";
    internalInterface = mkOption {
      type = types.str;
      default = "eth0";
      description = "The internal interface to use.";
    };
    externalInterface = mkOption {
      type = types.str;
      default = "eth1";
      description = "The external interface to use.";
    };
  };
  };

  config = mkIf cfg.enable {

  services.dnsmasq = {
    enable = true;
    servers = [ "8.8.8.8" "8.8.4.4" ];
    extraConfig = ''
      interface=${cfg.internalInterface}
      dhcp-range=192.168.1.10,192.168.1.250,255.255.255.0,24h
      dhcp-authoritative
      log-queries
      log-facility=/var/log/dnsmasq.log
      no-resolv
    '';
  };


  networking.firewall.allowedTCPPorts = [ 53  ];

  networking.interfaces.eth1.useDHCP = true;
  networking.interfaces.eth1.ipv4.addresses = [
    {
      address = "10.10.1.2";
      prefixLength = 24;
    }
  ];

  networking.nat = {
    enable = true;
    internalInterfaces = [ cfg.internalInterface ];
    externalInterface = cfg.externalInterface;
  };

  };

}
