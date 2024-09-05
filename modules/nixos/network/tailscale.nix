{
  config,
  lib,
  pkgs,
  self,
  ...
}:
with lib; let
  cfg = config.chr.system.network.tailscale;
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
      interfaceName = mkOption {
        type = types.string;
        default = "ts0";
      };
    };
  };

  config = mkIf cfg.enable {
    age.secrets.tailscale-auth-key.file = ../../../secrets/tailscale-auth-key;

    environment.systemPackages = [pkgs.tailscale];

    networking.dhcpcd.denyInterfaces = [interfaceName];

    networking.firewall = {
      trustedInterfaces = [interfaceName];
    };

    systemd.network.networks."50-tailscale" = mkIf config.networking.useNetworkd {
      matchConfig = {
        Name = interfaceName;
      };
      linkConfig = {
        Unmanaged = true;
        ActivationPolicy = "manual";
      };
    };

    service.tailscale = {
      enable = true;
      interfaceName = cfg.interfaceName;
      authKeyFile = cfg.authKeyFile;
      openFirewall = true;
    };

    environment.persistence."${config.internal.system.state.stateDir}".directories =
      lib.mkIf config.internal.system.state.enable
      ["/var/lib/tailscale"];
  };
}