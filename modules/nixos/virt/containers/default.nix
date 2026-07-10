{ config, lib, flake, ... }:
let
  inherit (lib) mkIf mkDefault;
  inherit (flake.lib) mkBoolOpt mkStrOpt;
  cfg = config.virt.containers;

  # CIDR-Mask aus subnet extrahieren (z.B. "10.5.5.0/24" → "24")
  mask = lib.last (builtins.split "/" cfg.subnet);
in {
  options.virt.containers = {
    enable = mkBoolOpt false;

    bridge = mkStrOpt "br0";

    subnet = mkStrOpt "10.5.5.0/24";

    hostAddress = mkStrOpt "10.5.5.1";

    externalInterface = mkStrOpt "eth0";

    instances = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          ip = lib.mkOption {
            type = lib.types.str;
            description = "IP-Adresse auf dem Bridge-Netzwerk";
          };
          ports = lib.mkOption {
            type = lib.types.listOf (lib.types.submodule {
              options = {
                hostPort = lib.mkOption { type = lib.types.port; };
                containerPort = lib.mkOption { type = lib.types.port; };
                protocol = lib.mkOption {
                  type = lib.types.enum [ "tcp" "udp" ];
                  default = "tcp";
                };
              };
            });
            default = [ ];
            description = "Port-Forwardings von WAN zum Container";
          };
          secrets = lib.mkOption {
            type = lib.types.attrsOf (lib.types.submodule {
              options = {
                file = lib.mkOption {
                  type = lib.types.str;
                  description = "Dateiname in secrets/ (ohne .age)";
                };
                owner = lib.mkOption {
                  type = lib.types.str;
                  default = "root";
                };
                group = lib.mkOption {
                  type = lib.types.str;
                  default = "root";
                };
                mode = lib.mkOption {
                  type = lib.types.str;
                  default = "400";
                };
              };
            });
            default = { };
            description = ''
              Secrets aus agenix/ragenix die per bind mount
              in den Container gereicht werden.
            '';
          };
        };
      });
      default = { };
      description = "Container-Instanzen auf diesem Host";
    };
  };

  config = mkIf cfg.enable {
    boot.enableContainers = true;

    # Bridge für das interne Container-Netzwerk
    networking.bridges."${cfg.bridge}".interfaces = [ ];

    # Bridge bekommt eine IP (Host → Container, Gateway)
    systemd.network.networks."40-${cfg.bridge}" = {
      matchConfig.Name = cfg.bridge;
      address = [ "${cfg.hostAddress}/${mask}" ];
      linkConfig.RequiredForOnline = "no";
      networkConfig = {
        LinkLocalAddressing = "no";
        DHCPServer = "no";
        ConfigureWithoutCarrier = true;
      };
    };

    # Container aus instances definieren
    containers = lib.mapAttrs' (name: inst: {
      name = name;
      value = {
        autoStart = true;
        privateNetwork = true;
        hostBridge = cfg.bridge;
        localAddress = "${inst.ip}/${mask}";
        path = flake.nixosConfigurations."cnt-${name}".config.system.build.toplevel;

        # Secrets per bind mount in den Container
        bindMounts = lib.mapAttrs' (key: _: {
          name = "/run/secrets/${key}";
          value = {
            hostPath = "/run/secrets/${key}";
            isReadOnly = true;
          };
        }) inst.secrets;
      };
    }) cfg.instances;

    # NAT (Container → Internet) + DNAT (WAN → Container)
    networking.nat = {
      enable = true;
      externalInterface = cfg.externalInterface;
      internalInterfaces = [ cfg.bridge ];
      forwardPorts = lib.flatten (lib.mapAttrsToList (name: inst:
        map (p: {
          destination = "${inst.ip}:${toString p.containerPort}";
          proto = p.protocol;
          sourcePort = p.hostPort;
        }) inst.ports
      ) cfg.instances);
    };

    # Secrets auf dem Host entschlüsseln und bereitstellen
    age.secrets = lib.mkMerge (
      lib.mapAttrsToList (name: inst:
        lib.mapAttrs' (key: secretCfg: {
          name = key;
          value = {
            file = mkDefault "${flake}/secrets/${secretCfg.file}.age";
            owner = mkDefault secretCfg.owner;
            group = mkDefault secretCfg.group;
            mode = mkDefault secretCfg.mode;
          };
        }) inst.secrets
      ) cfg.instances
    );
  };
}
