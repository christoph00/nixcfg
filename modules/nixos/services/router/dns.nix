{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib
, # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs
, # You also have access to your flake's inputs.
  inputs
, # Additional metadata is provided by Snowfall Lib.
  namespace
, # The namespace used for your flake, defaulting to "internal" if not set.
  system
, # The system architecture for this host (eg. `x86_64-linux`).
  target
, # The Snowfall Lib target for this system (eg. `x86_64-iso`).
  format
, # A normalized name for the system target (eg. `iso`).
  virtual
, # A boolean to determine whether this system is a virtual target using nixos-generators.
  systems
, # An attribute map of your defined hosts.

  # All other arguments come from the module system.
  config
, ...
}:

with builtins;
with lib;
with lib.internal;

let
  cfg = config.internal.services.router.dns;

in

{

  options.internal.services.router.dns = {
    enable = mkBoolOpt config.internal.isRouter "Enable DNS Server.";

  };

  config = mkIf cfg.enable {

    internal.agent.allowedServices = [ "blocky" ];

    services.blocky = {
      enable = true;
      settings = {
        queryLog.type = "none";
        upstreams = {
          groups = {
            default = [
              "https://dns.digitale-gesellschaft.ch/dns-query"
              "tcp-tls:dns2.digitalcourage.de:853"
              "tcp-tls:dns3.digitalcourage.de:853"
              "tcp-tls:fdns1.dismail.de:853"
              "tcp-tls:one.one.one.one:853"
            ];
            unencrypted = [
              "1.0.0.1"
              "1.1.1.1"
              "2606:4700:4700::1001"
              "2606:4700:4700::1111"
              "dns2.digitalcourage.de"
            ];
          };
          timeout = "2s";
        };

        startVerifyUpstream = true;
        connectIPVersion = "dual";
        ports = {
          dns = 53;
          http = 4040;
        };

        caching = {
          minTime = "5m";
          prefetching = true;
        };
        customDNS = {
          mapping = {
            "lan.net.r505.de" = lib.mkDefault "127.0.0.11";
          };
        };
        hostsFile = {
          sources = [ "/etc/hosts" ];
          hostsTTL = "60m";
          filterLoopback = true;
          loading.refreshPeriod = "30m";
        };

        conditional = {
          rewrite = {
            ts.r505.de = "cama-boa.ts.net";
          };
          mapping = {
            "ts.net" = "100.100.100.100";
          };
        };
        bootstrapDns = "tcp+udp:1.1.1.1";
        blocking = {
          blackLists = {
            ads = [
              "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
            ];
          };
          clientGroupsBlock = {
            default = [ "ads" ];
          };
        };
      };
    };

  };
}
