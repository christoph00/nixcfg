{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib
, # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs
, # You also have access to your flake's inputs.
  inputs
, # Additional metadata is provided by Snowfall Lib.
  namespace
, # The namespace used for your flake, defaulting to "internal" if not set.
  system
, # The system architecture for this host (eg. `x86_64-linux`).
  target
, # The Snowfall Lib target for this system (eg. `x86_64-iso`).
  format
, # A normalized name for the system target (eg. `iso`).
  virtual
, # A boolean to determine whether this system is a virtual target using nixos-generators.
  systems
, # An attribute map of your defined hosts.

  # All other arguments come from the module system.
  config
, ...
}:

with builtins;
with lib;
with lib.internal;

let
  cfg = config.internal.services.agent;
  format = pkgs.formats.json { };


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
    settings = mkOption {
      type = format.type;
      default = { };
      example = literalExpression ''
        {
          broker = {
            host = "mqtt.local";
            port = 1883;
          };
          mqtt_user = "mqtt-host-agent";
          allowedServices = [ "nginx" "postgresql" ];
          allowedCommands = {
            update = "nixos-rebuild switch";
            uptime = "uptime";
          };
          watchServices = [ "nginx" ];
        }
      '';
      description = "Configuration for MQTT Host Agent";
    };
  };

  config = mkIf cfg.enable {
    internal.services.agent.settings = lib.mkDefault {

      broker = {
        host = "lsrv";
        port = 1883;
      };
      mqtt_user = "ha";
      allowedServices = [ ];
      allowedCommands = {
        update_switch = "nh os switch github:christoph00/nixcfg -- --refresh --accept-flake-config";
        update_boot = "nh os boot github:christoph00/nixcfg -- --refresh --accept-flake-config";
        clean_os = "nh clean all";
        reboot = "systemctl reboot";
        shutdown = "systemctl shutdown";
      };
      watchServices = [ ];
    };



    age.secrets.mqtt-agent.file = ../../../../secrets/mqtt-ha.age;

    systemd.services.mqtt-host-agent = {
      description = "MQTT Host Agent Service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/mqtt-host-agent ${format.generate "mqtt-host-agent-config.json" cfg.settings}";
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

