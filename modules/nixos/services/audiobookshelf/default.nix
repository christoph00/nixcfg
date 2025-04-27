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
  cfg = config.internal.services.audiobookshelf;

in
{

  options.internal.services.audiobookshelf = {
    enable = mkBoolOpt false "Enable audiobookshelf Service.";
    domain = mkOption {
      type = types.str;
      default = "bs.r505.de";
      description = "The domain to use for the audiobookshelf service.";
    };

  };

  config = mkIf cfg.enable {

    internal.system.state.directories = [ "/var/lib/audiobookshelf" ];

    services.audiobookshelf = {
      enable = true;
    };
    services.nginx.virtualHosts."${cfg.domain}" = {
      useACMEHost = "r505.de";
      forceSSL = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.audiobookshelf.port}";
        recommendedProxySettings = true;
        proxyWebsockets = true;
      };
    };

  };

}
