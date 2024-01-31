{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.system.containers;
in {
  options.chr.system.containers = with types; {
    enable =
      mkBoolOpt false "Whether or not to configure containers.";
    externalInterface = mkOption {
      type = types.str;
      default = "ens5";
      description = "External network interface to use for containers.";
    };
  };

  config = mkIf cfg.enable {
    networking.nat = {
      enable = true;
      internalInterfaces = [
        "podman0"
      ];
      externalInterface = cfg.externalInterface;
    };

    virtualisation = {
      podman = {
        enable = true;
      };
      oci-containers = {
        backend = "podman";
      };
    };
  };
}
