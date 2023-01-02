{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.conf.network;
in {
  options.conf.network = {
    enable = mkEnableOption "NetworkConfig";
    wireless = mkOption {
      type = types.bool;
      default = false;
    };
    interface = mkOption {
      type = types.string;
      default = "eth0";
    };
  };

  config = mkIf cfg.enable {
    users.groups.network = {};

    networking.networkmanager.enable = false;

    networking.firewall.allowPing = true;

    networking.useNetworkd = lib.mkDefault true;
    networking.useDHCP = lib.mkDefault false;

    systemd.services.NetworkManager-wait-online.enable = false;
    systemd.network.wait-online.enable = false;

    # FIXME: Maybe upstream?
    # Do not take down the network for too long when upgrading,
    # This also prevents failures of services that are restarted instead of stopped.
    # It will use `systemctl restart` rather than stopping it with `systemctl stop`
    # followed by a delayed `systemctl start`.
    systemd.services.systemd-networkd.stopIfChanged = false;
    # Services that are only restarted might be not able to resolve when resolved is stopped before
    systemd.services.systemd-resolved.stopIfChanged = false;

    systemd.network.networks = {
      lan = {
        DHCP = "yes";
        matchConfig.Name = "en*";
      };
      wifi = mkIf cfg.wireless {
        DHCP = "yes";
        matchConfig.Name = "wl*";
      };
    };

    networking.wireless = mkIf cfg.wireless {
      enable = false;
      iwd.enable = true;
      fallbackToWPA2 = false;

      # Imperative
      allowAuxiliaryImperativeNetworks = true;
      userControlled = {
        enable = true;
        group = "network";
      };
      extraConfig = ''
        update_config=1
      '';
    };

    # TODO: Check if Home Net
    networking.domain = "lan.net.r505.de";

    environment.persistence."/persist" = {
      directories = [
        "/var/lib/iwd"
      ];
    };
  };
}
