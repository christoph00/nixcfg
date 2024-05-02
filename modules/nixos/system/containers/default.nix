{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.chr;
let
  cfg = config.chr.system.containers;
in
{
  options.chr.system.containers = with types; {
    enable = mkBoolOpt false "Whether or not to configure containers.";
    externalInterface = mkOption {
      type = types.str;
      default = "ens5";
      description = "External network interface to use for containers.";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall = {
      trustedInterfaces = [ "podman0" ];
      interfaces."podman+".allowedUDPPorts = [ 53 ];
      interfaces."podman+".allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [ 53 ];
    };

    virtualisation = {
      podman = {
        enable = true;
        dockerSocket.enable = true;
        autoPrune = {
          enable = true;
          dates = "daily";
          flags = [ "--all" ];
        };
      };
      oci-containers = {
        backend = "podman";
      };
    };
  };
}
