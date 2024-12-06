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
  cfg = config.internal.services.agent;
  format = pkgs.formats.json { };
  mkServiceCommand = service: {
    "${service}" = "${pkgs.systemd}/bin/systemctl";
  };

  mkServiceDiscoveryConfig = service: {
    component = "select";
    name = "Service ${service}";
    unique_id = "service_${service}_control";
    command_topic = "mqd/${config.networking.hostName}/command/systemctl";
    command_template = ''{"command": "systemctl", "arguments": ["{{ value }}", "${service}"]}'';
    options = [
      "start"
      "stop"
      "restart"
      "status"
    ];
    state_topic = "mqd/${config.networking.hostName}/command/systemctl/result";
    value_template = "{{ value_json.output }}";
    icon = "mdi:cog";
    device = {
      identifiers = [ config.networking.hostName ];
      name = "${config.networking.hostName}";
      model = "MQTT Host Agent";
      manufacturer = "NixOS";
    };
  };

  serviceCommands = lib.foldl (
    acc: service: acc // (mkServiceCommand service)
  ) { } cfg.allowedServices;

  # Home Assistant Discovery Configs
  serviceDiscoveryConfigs = lib.foldl (
    acc: service: acc // { ${service} = mkServiceDiscoveryConfig service; }
  ) { } cfg.allowedServices;

  baseConfig = {
    broker = {
      inherit (cfg.broker) host port;
    };
    mqtt_user = cfg.mqtt.user;
    allowedCommands = serviceCommands // cfg.extraCommands;
    haDiscovery = {
      services = serviceDiscoveryConfigs;
    };
  };

in

{

  options.internal.services.agent = {
    enable = mkBoolOpt true "Enable MQTT Command Daemon.";

    package = mkOption {
      type = types.package;
      default = pkgs.internal.mqtt-host-agent;
    };

    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = config.age.secrets.mqtt-agent.path;
    };

    broker = {
      host = mkOption {
        type = types.str;
        description = "MQTT Broker hostname";
        default = "lsrv";
      };

      port = mkOption {
        type = types.port;
        default = 1883;
        description = "MQTT Broker port";
      };
    };

    mqtt = {
      user = mkOption {
        type = types.str;
        default = "ha";
      };
    };

    allowedServices = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [
        "nginx"
        "postgresql"
      ];
      description = "List of services that can be controlled via MQTT";
    };

    extraCommands = mkOption {
      type = types.attrsOf types.str;
      default = { };
      example = literalExpression ''
        {
          update = "''${pkgs.nixos-rebuild}/bin/nixos-rebuild switch";
          reboot = "''${pkgs.systemd}/bin/systemctl reboot";
        }
      '';
      description = "Additional commands that can be executed via MQTT";
    };

  };

  config = mkIf cfg.enable {
    internal.services.agent = lib.mkDefault {

      extraCommands = {
        systemctl = "${pkgs.systemd}/bin/systemctl";
        poweroff = "${pkgs.systemd}/bin/systemctl poweroff";
        reboot = "${pkgs.systemd}/bin/systemctl reboot";
        nh-os-switch = "${pkgs.nh}/bin/nh os boot github:christoph00/nixcfg -- --refresh --accept-flake-config";
        nh-os-boot = "${pkgs.nh}/bin/nh os boot github:christoph00/nixcfg -- --refresh --accept-flake-config";
        nh-clean-all = "${pkgs.nh}/bin/nh clean all";

      };
    };

    age.secrets.mqtt-agent.file = ../../../../secrets/mqtt-agent.age;

    systemd.services.mqtt-host-agent = {
      description = "MQTT Host Agent Service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/mqtt-host-agent ${format.generate "mqtt-host-agent-config.json" baseConfig}";
        # DynamicUser = true;
        EnvironmentFile = mkIf (cfg.environmentFile != null) [ cfg.environmentFile ];

        # Hardening
        # CapabilityBoundingSet = [ "CAP_DAC_READ_SEARCH" ];
        # DevicePolicy = "closed";
        # LockPersonality = true;
        # MemoryDenyWriteExecute = true;
        # NoNewPrivileges = true;
        # PrivateDevices = true;
        # PrivateTmp = true;
        # PrivateUsers = true;
        # ProtectClock = true;
        # ProtectControlGroups = true;
        # ProtectHome = true;
        # ProtectHostname = true;
        # ProtectKernelLogs = true;
        # ProtectKernelModules = true;
        # ProtectKernelTunables = true;
        # ProtectSystem = "strict";
        # ReadWritePaths = [ ];
        # RemoveIPC = true;
        # RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
        # RestrictNamespaces = true;
        # RestrictRealtime = true;
        # RestrictSUIDSGID = true;
        # SystemCallArchitectures = "native";
        # SystemCallFilter = [ "@system-service" ];
        # UMask = "0077";
      };
    };

  };
}
