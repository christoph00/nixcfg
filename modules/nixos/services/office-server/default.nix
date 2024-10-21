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
  cfg = config.internal.services.office-server;

in

{

  options.internal.services.office-server = {
    enable = mkBoolOpt false "Enable Office-Server.";
  };

  config = mkIf cfg.enable {

    internal.services.container.enable = true;

    services.nginx.enable = true;
    security.acme.acceptTerms = true;
    security.acme.defaults.email = "chr@asche.co";

    virtualisation.oci-containers.containers.collabora-office =
      let
        inherit (config.users.users.collabora-office) uid;
        inherit (config.users.groups.collabora-office) gid;
      in
      {
        image = "docker.io/collabora/code";
        ports = [ "9980:9980" ];
        environment =
          let
            mkAlias = domain: "https://" + (builtins.replaceStrings [ "." ] [ "\\." ] domain) + ":443";
          in
          {
            server_name = "office.r505.de";
            aliasgroup1 = mkAlias "office.r505.de";
            aliasgroup2 = mkAlias "cloud.r505.de";
            aliasgroup3 = mkAlias "cloud.kinderkiste-hannover.de";
            extra_params = "--o:ssl.enable=false --o:ssl.termination=true";
          };
        extraOptions = [
          "--uidmap=0:65534:1"
          "--gidmap=0:65534:1"
          "--uidmap=100:${toString uid}:1"
          "--gidmap=101:${toString gid}:1"
          "--network=host"
          "--cap-add=MKNOD"
          "--cap-add=CHOWN"
          "--cap-add=FOWNER"
          "--cap-add=SYS_CHROOT"
          "--label=io.containers.autoupdate=registry"
        ];
      };

    services.nginx.virtualHosts."office.r505.de" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:9980";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_read_timeout 36000s;
        '';
      };
    };

    users.users.collabora-office = {
      isSystemUser = true;
      group = "collabora-office";
      uid = 982;
    };

    users.groups.collabora-office = {
      gid = 982;
    };

  };

}
