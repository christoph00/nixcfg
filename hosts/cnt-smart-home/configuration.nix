{ lib, ... }: {
  imports = [ ../../modules/nixos/container-base.nix ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  networking.hostName = "smarthome";

  # Mosquitto MQTT Broker
  services.mosquitto.enable = true;

  # Home Assistant — nutzt perSystem.nixpkgs-unstable via Modul
  services.home-assistant = {
    enable = true;
    config.homeassistant.name = lib.mkForce "SmartHome Test";
    config.homeassistant.unit_system = lib.mkForce "metric";
    config.homeassistant.time_zone = lib.mkForce "Europe/Berlin";
    config.http = lib.mkForce {
      server_host = "0.0.0.0";
      server_port = 8123;
      use_x_forwarded_for = true;
      trusted_proxies = [ "10.88.0.0/24" ];
    };
  };

  system.stateVersion = "25.11";
}
