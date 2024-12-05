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

  generateCommands = services:
    let
      makeServiceCommands = name: service: ''
        "mqd/$HOSTNAME/cmd/${name}-start")
            ${pkgs.systemd}/bin/systemctl --user start ${name}.service
            ;;
        "mqd/$HOSTNAME/cmd/${name}-stop")
            ${pkgs.systemd}/bin/systemctl --user stop ${name}.service
            ;;
        "mqd/$HOSTNAME/cmd/${name}-status")
            status=$(${pkgs.systemd}/bin/systemctl --user status ${name}.service)
            ${pkgs.mosquitto}/bin/mosquitto_pub -h "$MQTT_HOST" -p "$MQTT_PORT" \
                -u "$MQTT_USER" -P "$MQTT_PASS" \
                -t "mqd/$HOSTNAME/status" -m "$status"
            ;;
      '';
      serviceCommands = lib.mapAttrsToString makeServiceCommands services;
    in serviceCommands;
in

{

  options.internal.services.agent = {
    enable = mkBoolOpt true "Enable MQTT Command Daemon.";
  };

  config = mkIf cfg.enable {
  systemd.services.mqtt-daemon = {
    description = "MQTT Command Daemon";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.bash}/bin/bash ${pkgs.writeScript "mqtt-daemon" ''
        #!${pkgs.bash}/bin/bash

        # Konfiguration
        HOSTNAME=${networking.hostName}
        MQTT_HOST="lsrv"
        MQTT_PORT="1883"
        MQTT_USER="ha"
        MQTT_PASS="ha"

        send_heartbeat() {
            while true; do
                ${pkgs.mosquitto}/bin/mosquitto_pub -h "$MQTT_HOST" -p "$MQTT_PORT" \
                    -u "$MQTT_USER" -P "$MQTT_PASS" \
                    -t "mqd/$HOSTNAME/heartbeat" -m "online"
                sleep 30
            done
        }

        listen_commands() {
            while true; do
                ${pkgs.mosquitto}/bin/mosquitto_sub -h "$MQTT_HOST" -p "$MQTT_PORT" \
                    -u "$MQTT_USER" -P "$MQTT_PASS" \
                    -t "mqd/$HOSTNAME/cmd/+" | while read -r topic payload; do
                    case "$topic" in
                        ${generateCommands cfg.services}
                    esac
                done
                sleep 10
            done
        }

        send_heartbeat &
        listen_commands &

        wait
      ''}";
      Restart = "always";
      RestartSec = "10";
    };
  };
};
}