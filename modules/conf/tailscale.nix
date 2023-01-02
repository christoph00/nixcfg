# https://tailscale.com/blog/nixos-minecraft/
{
  pkgs,
  lib,
  config,
  self,
  ...
}:
with lib; let
  cfg = config.conf.network.tailscale;
in {
  options.conf.network.tailscale = {
    enable = mkEnableOption "tailscale";

    package = mkOption {
      type = types.package;
      default = pkgs.tailscale;
    };

    service = mkOption {
      type = types.bool;
      default = true;
      description = ''
        if a systemd service should be used to authenticate with tailscale (should only be activated if host key is added in secrets.nix)
      '';
    };

    magicDNS = mkOption {
      type = types.str;
      default = "false";
      description = ''
        sets --accept-dns (should be true or false)
      '';
    };

    exitNode = mkOption {
      type = types.str;
      default = "false";
      description = ''
        sets --advertise-exit-node and ip forwarding
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge
    [
      {
        services.tailscale = {
          inherit (cfg) enable package;
        };

        networking.firewall.trustedInterfaces = [config.services.tailscale.interfaceName];
        networking.firewall.allowedUDPPorts = [config.services.tailscale.port];
        # little workaround TODO: see if still needed in some time
        networking.firewall.checkReversePath = "loose";
      }
      (mkIf cfg.service {
        systemd.services.tailscale-autoauth = {
          description = "Uses preauth key to connect to tailscale";

          after = ["network-pre.target" "tailscale.service"];
          wants = ["network-pre.target" "tailscale.service"];
          wantedBy = ["multi-user.target"];

          serviceConfig.Type = "oneshot";

          script = ''
            ${cfg.package}/bin/tailscale up --authkey="$(cat ${config.age.secrets.tailscale-preauthkey.path})" --accept-dns=${cfg.magicDNS} --advertise-exit-node=${cfg.exitNode}
          '';
        };
      })
      (mkIf (cfg.exitNode != "false") {
        boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
        boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = 1;
      })

      (
        mkIf config.conf.base.persist {
          environment.persistence."/persist" = {
            directories = [
              "/var/lib/tailscale"
            ];
          };
        }
      )
    ]);
}
