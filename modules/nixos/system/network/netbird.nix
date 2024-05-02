{
  config,
  lib,
  pkgs,
  self,
  ...
}:
with lib;
let
  cfg = config.chr.system.network.netbird;
  kernel = config.boot.kernelPackages;
  interfaceName = "wt0";
in
{
  options.chr.system.network.netbird = {
    enable = mkOption {
      type = types.bool;
      default = true;
    };
    package = mkOption {
      type = types.package;
      default = pkgs.netbird;
      defaultText = literalExpression "pkgs.netbird";
      description = lib.mdDoc "The package to use for netbird";
    };
    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = config.age.secrets.netbirdenv.path;
      description = lib.mdDoc ''
        File containing environment variables to be passed to the netbird service.
      '';
    };
  };

  config = mkIf cfg.enable {
    boot.extraModulePackages = optional (versionOlder kernel.kernel.version "5.6") kernel.wireguard;

    age.secrets.netbirdenv.file = ../../../../secrets/netbird.env;

    environment.systemPackages = [ cfg.package ];

    networking.dhcpcd.denyInterfaces = [ interfaceName ];

    networking.firewall = {
      trustedInterfaces = [ interfaceName ];
      checkReversePath = "loose";
      allowedUDPPorts = [ 51820 ];
    };

    systemd.network.networks."50-netbird" = mkIf config.networking.useNetworkd {
      matchConfig = {
        Name = interfaceName;
      };
      linkConfig = {
        Unmanaged = true;
        ActivationPolicy = "manual";
      };
    };

    systemd.services.netbird = {
      description = "A WireGuard-based mesh network that connects your devices into a single private network";
      documentation = [ "https://netbird.io/docs/" ];
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [ openresolv ];
      serviceConfig = {
        EnvironmentFile = cfg.environmentFile;
        ExecStart = "${cfg.package}/bin/netbird up --foreground-mode -c /var/lib/netbird/config.json --log-file console";
        Restart = "always";
        RuntimeDirectory = "netbird";
        StateDirectory = "netbird";
        WorkingDirectory = "/var/lib/netbird";
      };
      unitConfig = {
        StartLimitInterval = 5;
        StartLimitBurst = 10;
      };
      stopIfChanged = false;
    };
    environment.persistence."${config.chr.system.persist.stateDir}".directories =
      lib.mkIf config.chr.system.persist.enable
        [ "/var/lib/netbird" ];
  };
}
