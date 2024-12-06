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
  cfg = config.internal.services.router.dhcp;

in

{

  options.internal.services.router.dhcp = {
    enable = mkBoolOpt config.internal.isRouter "Enable DHCP Server.";

  };

  config = mkIf cfg.enable {

    #    internal.system.state.directories = [ "/var/lib/private/technitium-dns-server" ];
    # services.technitium-dns-server = {
    #   enable = true;
    # };

    internal.system.state.directories = [ "/var/lib/private/kea" ];
    services.kea = {
      dhcp4 = {
        enable = true;
        settings = {
          lease-database = {
            name = "/var/lib/kea/dhcp4.leases";
            persist = true;
            type = "memfile";
          };
          rebind-timer = 2000;
          renew-timer = 1000;
          valid-lifetime = 4000;

          ddns-replace-client-name = "when-not-present";
          ddns-override-client-update = true;
          ddns-override-no-update = true;
        };
      };

      dhcp-ddns = {
        enable = true;
        settings = {
          ip-address = "127.0.0.11";
          port = 53001;
          dns-server-timeout = 100;
          ncr-protocol = "UDP";
          ncr-format = "JSON";

          control-socket = {
            socket-type = "unix";
            socket-name = "/run/kea/ddns.socket";
          };

          forward-ddns = {
            ddns-domains = [
              {
                name = "home.net.r505.de.";
                dns-servers = [
                  {
                    hostname = "";
                    ip-address = "127.0.0.11";
                    port = 53;
                  }
                ];
              }
            ];
          };
          reverse-ddns = {
            ddns-domains = [
              {
                name = "2.168.192.in-addr.arpa.";
                dns-servers = [
                  {
                    hostname = "";
                    ip-address = "127.0.0.11";
                    port = 53;
                  }
                ];
              }
            ];
          };
        };
      };
    };

    services.kea.dhcp4.settings = {
      interfaces-config.interfaces = [ "lan" ];
      subnet4 = [
        {
          id = 1;
          interface = "lan";
          pools = [ { pool = "192.168.2.51 - 192.168.2.249"; } ];
          subnet = "192.168.2.0/24";

          option-data = [
            {
              name = "routers";
              data = "192.168.2.2";
            }
            {
              name = "domain-name-servers";
              data = "192.168.2.2";
            }
            {
              name = "domain-name";
              data = "lan.net.r505.de";
            }
          ];

          ddns-qualifying-suffix = "lan.net.r505.de";

        }
      ];
    };

    networking.interfaces.lo.ipv4.addresses = [
      {
        address = "127.0.0.11";
        prefixLength = 8;
      }
    ];

    services.knot = {
      enable = true;
      settings = {
        server.listen = [ "127.0.0.11@53" ];
        acl = {
          internal_ddns_transfer = {
            address = [ "127.0.0.1" ];
            action = [
              "update"
              "transfer"
            ];
          };
        };
        template = {
          home = {
            semantic-checks = true;
            acl = [ "internal_ddns_transfer" ];
            zonefile-load = "none";
            zonefile-sync = -1;
            journal-content = "all";
          };
        };
        zone = {

        };
      };

    };

  };

}
