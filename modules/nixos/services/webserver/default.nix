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
  cfg = config.internal.services.webserver;

in

{

  options.internal.services.webserver = {
    enable = mkBoolOpt false "Enable Webserver.";

  };

  config = mkIf cfg.enable {

    users.users.caddy.isSystemUser = true;
    users.users.caddy.group = "caddy";
    users.groups.caddy = { };

    services.caddy = {
      enable = true;

      package = pkgs-caddy.caddy.override {
        externalPlugins = [
          {
            name = "cloudflare";
            repo = "github.com/caddy-dns/cloudflare";
            version = "89f16b99c18ef49c8bb470a82f895bce01cbaece";
          }
        ];
        vendorHash = "sha256-fTcMtg5GGEgclIwJCav0jjWpqT+nKw2OF1Ow0MEEitk=";
      };
    };


    systemd.services.caddy.serviceConfig.AmbientCapabilities = "CAP_NET_BIND_SERVICE";

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    networking.firewall.allowedUDPPorts = [ 443 ];


  };

}
