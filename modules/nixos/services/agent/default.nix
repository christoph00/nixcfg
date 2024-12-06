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

  commandType = types.submodule {
    options = {
      name = mkOption {
        type = types.str;
      };
      command = mkOption {
        type = types.str;
      };
      user = mkOption {
        type = types.str;
        default = "root";
      };
    };
  };
in

{

  options.internal.services.agent = {
    enable = mkBoolOpt true "Enable MQTT Command Daemon.";

    mqtt = {
      host = mkOption {
        type = types.str;
        default = "lsrv";
        description = "MQTT Broker Host";
      };
      port = mkOption {
        type = types.port;
        default = 1883;
        description = "MQTT Broker Port";
      };
      username = mkOption {
        type = types.str;
        default = "agent";
      };
    };

    commands = mkOption {
      type = types.listOf commandType;
      default = [
      ];
      example = literalExpression ''
        [
          {
            name = "reboot";
            command = "systemctl reboot";
            user = "root";
          }
          {
            name = "scale-display";
            command = "wlr-randr --output HEADLESS-1 --scale 2";
            user = "myuser";
          }
        ]
      '';
    };

    config = mkIf cfg.enable {
      age.secrets.mqtt-agent.file = ../../../../secrets/mqtt-agent.age;

      systemd.services.mqtt-commander = {
        description = "MQTT Command Daemon";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "simple";
          EnvironmentFile = config.age.secrets.mqtt-agent.path;
          ExecStart =
            let
              generateCommands =
                commands:
                concatStringsSep "\n" (
                  map
                    (cmd: ''
                      "mqd/$HOSTNAME/cmd/${cmd.name}")
                          ${if cmd.user == "root" then "${cmd.command}" else "doas -u ${cmd.user} ${cmd.command}"}
                          ;;
                    '')
                    commands
                );
            in
            pkgs.writeScript "mqtt-commander" ''
              #!${pkgs.bash}/bin/bash

              MQTT_HOST="${cfg.mqtt.host}"
              MQTT_PORT="${toString cfg.mqtt.port}"
              MQTT_USER="${cfg.mqtt.username}"

              send_heartbeat() {
                  while true; do
                      ${pkgs.mosquitto}/bin/mosquitto_sub -h "$MQTT_HOST" -p "$MQTT_PORT" -u "$MQTT_USER" -P "$MQTT_PASS" \
                          -t "mqd/${config.networking.hostName}/heartbeat" -m "online"
                      sleep 30
                  done
              }

              listen_commands() {
                  while true; do
                      ${pkgs.mosquitto}/bin/mosquitto_sub -h "$MQTT_HOST" -p "$MQTT_PORT" -u "$MQTT_USER" -P "$MQTT_PASS" \
                          -t "mqd/${config.networking.hostName}/cmd/+" | while read -r topic payload; do
                          case "$topic" in
                              ${generateCommands cfg.commands}
                              *)
                                  echo "Unkown Command: $topic"
                                  ;;
                          esac
                      done
                      sleep 10
                  done
              }

              send_heartbeat &
              listen_commands &
              wait
            '';
          Restart = "always";
          RestartSec = "10";
        };
      };
    };
  };
}
