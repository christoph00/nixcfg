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
  baseDeviceConfig = {
    identifiers = [ "agent-${config.networking.hostName}" ];
    name = "${config.networking.hostName}";
    model = "MQTT Host Agent";
    manufacturer = "NixOS";
  };

  # Basis MQTT-Topics
  mqttBase = "mqd/${config.networking.hostName}";

  # Service Discovery Konfiguration
  mkServiceDiscoveryConfig = service: {
    component = "select";
    name = "Service ${service}";
    unique_id = "service_${service}_control";
    command_topic = "${mqttBase}/command/systemctl";
    command_template = ''{"command": "systemctl", "arguments": ["{{ value }}", "${service}"]}'';
    options = [
      "start"
      "stop"
      "restart"
      "status"
    ];
    state_topic = "${mqttBase}/command/systemctl/result";
    value_template = "{{ value_json.output }}";
    json_attributes_topic = "${mqttBase}/command/systemctl/result";
    json_attributes_template = ''
      {
        "last_command": "{{ value_json.command }}",
        "status_code": {{ value_json.status_code }},
        "timestamp": "{{ value_json.timestamp }}",
        "service": "${service}"
      }
    '';
    icon = "mdi:cog";
    entity_category = "config";
    device = baseDeviceConfig;
  };

  # Command Discovery Konfiguration
  mkCommandDiscoveryConfig = cmd: {
    component = "button";
    name = "Command ${cmd}";
    unique_id = "command_${cmd}";
    command_topic = "${mqttBase}/command/${cmd}";
    state_topic = "${mqttBase}/command/${cmd}/result";
    payload_press = "{}";
    json_attributes_topic = "${mqttBase}/command/${cmd}/result";
    json_attributes_template = ''
      {
        "status_code": {{ value_json.status_code }},
        "timestamp": "{{ value_json.timestamp }},
        "last_output": "{{ value_json.output | truncate(100) }}"
      }
    '';
    availability_topic = "${mqttBase}/status";
    availability_template = "{{ 'online' if value == 'online' else 'offline' }}";
    icon = "mdi:console";
    entity_category = "config";
    device = baseDeviceConfig;
  };

  mkOnlineStatusSensorConfig = {
    component = "binary_sensor";
    name = "${config.networking.hostName} Online Status";
    unique_id = "${config.networking.hostName}_online_status";
    state_topic = "${mqttBase}/heartbeat";
    value_template = ''{{ 'ON' if ((as_timestamp(now()) - as_timestamp(value)) | int < 50) else 'OFF' }}'';
    payload_on = "ON";
    payload_off = "OFF";
    device_class = "connectivity";
    expire_after = 50;
    icon = "mdi:server-network";
    device = baseDeviceConfig;
  };

  # Status Sensor Konfiguration
  mkStatusSensorConfig = {
    component = "sensor";
    name = "${config.networking.hostName} Status";
    unique_id = "${config.networking.hostName}_agent_status";
    state_topic = "${mqttBase}/status";
    json_attributes_topic = "${mqttBase}/heartbeat";
    icon = "mdi:server";
    device = baseDeviceConfig;
  };

  # Discovery Configs generieren
  serviceDiscoveryConfigs = lib.foldl (
    acc: service: acc // { ${service} = mkServiceDiscoveryConfig service; }
  ) { } cfg.allowedServices;

  commandDiscoveryConfigs = lib.foldl (
    acc: cmd: acc // { ${cmd} = mkCommandDiscoveryConfig cmd; }
  ) { } (builtins.attrNames cfg.extraCommands);

  # Basis-Konfiguration
  baseConfig = {
    broker = {
      inherit (cfg.broker) host port;
    };
    mqtt_user = cfg.mqtt.user;
    allowedCommands = cfg.extraCommands;
    haDiscovery = {
      services = serviceDiscoveryConfigs;
      commands = commandDiscoveryConfigs;
      status = mkStatusSensorConfig;
      online_status = mkOnlineStatusSensorConfig;
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
        default = "agent";
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
    internal.services.agent.extraCommands = {
      systemctl = "${pkgs.systemd}/bin/systemctl";
      poweroff = "${pkgs.systemd}/bin/systemctl poweroff";
      reboot = "${pkgs.systemd}/bin/systemctl reboot";
      nh-os-switch = "${pkgs.nh}/bin/nh os boot github:christoph00/nixcfg -- --refresh --accept-flake-config";
      nh-os-boot = "${pkgs.nh}/bin/nh os boot github:christoph00/nixcfg -- --refresh --accept-flake-config";
      nh-clean-all = "${pkgs.nh}/bin/nh clean all";
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
