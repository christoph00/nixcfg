{ config, lib, pkgs, self, ... }:
with lib;
let
  cfg = config.internal.system.network.tailscale;
  kernel = config.boot.kernelPackages;
in {
  options.internal.system.network.tailscale = {
    enable = mkOption {
      type = types.bool;
      default = true;
    };
    authKeyFile = mkOption {
      type = types.nullOr types.path;
      default = config.age.secrets.tailscale-auth-key.path;
    };
    interfaceName = mkOption {
      type = types.str;
      default = "ts0";
    };
  };

  config = mkIf cfg.enable {
    age.secrets.tailscale-auth-key.file = ../../../secrets/tailscale-auth-key;

    environment.systemPackages = [ pkgs.tailscale ];

    networking.dhcpcd.denyInterfaces = [ cfg.interfaceName ];

    networking.firewall = { trustedInterfaces = [ cfg.interfaceName ]; };

    systemd.network.networks."50-tailscale" =
      mkIf config.networking.useNetworkd {
        matchConfig = { Name = cfg.interfaceName; };
        linkConfig = {
          Unmanaged = true;
          ActivationPolicy = "manual";
        };
      };

    services.tailscale = {
      enable = true;
      interfaceName = cfg.interfaceName;
      authKeyFile = cfg.authKeyFile;
      openFirewall = true;
    };

    internal.system.state.directories = [ "/var/lib/tailscale" ];

  };
}
