{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib,
  # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs,
  # You also have access to your flake's inputs.
  inputs,

  # Additional metadata is provided by Snowfall Lib.
  namespace, # The namespace used for your flake, defaulting to "internal" if not set.
  system, # The system architecture for this host (eg. `x86_64-linux`).
  target, # The Snowfall Lib target for this system (eg. `x86_64-iso`).
  format, # A normalized name for the system target (eg. `iso`).
  virtual, # A boolean to determine whether this system is a virtual target using nixos-generators.
  systems, # An attribute map of your defined hosts.

  # All other arguments come from the module system.
  config,

  ...
}:

with builtins;
with lib;
with lib.internal;

let
  cfg = config.internal.services.wolf;
in

{

  options.internal.services.wolf = {
    enable = mkBoolOpt false "Enable Wolf Service.";
  };

  config = mkIf cfg.enable {

  security.rtkit.enable = true;
  services.pipewire = {
  enable = true;
  alsa.enable = true;
  alsa.support32Bit = true;
  pulse.enable = true;
  # If you want to use JACK applications, uncomment this
  #jack.enable = true;
};

    users.users = {
      wolf = {
        isNormalUser = true;
        linger = true;
        extraGroups = [
          "wheel"
          "networkmanager"
          "input"
        ];
      };
    };
    services.udev.extraRules = ''
      # Allows Wolf to acces /dev/uinput
      KERNEL=="uinput", SUBSYSTEM=="misc", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
      # Move virtual keyboard and mouse into a different seat
      SUBSYSTEMS=="input", ATTRS{id/vendor}=="ab00", MODE="0660", GROUP="input", ENV{ID_SEAT}="seat9"
      # Joypads
      SUBSYSTEMS=="input", ATTRS{name}=="Wolf X-Box One (virtual) pad", MODE="0660", GROUP="input"
      SUBSYSTEMS=="input", ATTRS{name}=="Wolf PS5 (virtual) pad", MODE="0660", GROUP="input"
      SUBSYSTEMS=="input", ATTRS{name}=="Wolf gamepad (virtual) motion sensors", MODE="0660", GROUP="input"
      SUBSYSTEMS=="input", ATTRS{name}=="Wolf Nintendo (virtual) pad", MODE="0660", GROUP="input"
    '';
    virtualisation.oci-containers.backend = "docker";
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.containers.wolf = {
      autoStart = true;
      image = "ghcr.io/games-on-whales/wolf:stable";
      volumes = [
        "/dev/input:/dev/input:rw"
        "/run/udev:/run/udev:rw"
        "/mnt/state/wolf:/data/wolf:rw"
        # TODO: Restore when podman works.
        # "/run/podman/podman.sock:/run/podman/podman.sock:rw"
        "/var/run/docker.sock:/var/run/docker.sock"
      ];
      environment = {
        WOLF_LOG_LEVEL = "INFO";
        HOST_APPS_STATE_FOLDER = "/data/wolf";
        XDG_RUNTIME_DIR = "/data/wolf/sockets";
        WOLF_CFG_FILE = "/data/wolf/cfg/config.toml";
        WOLF_PRIVATE_KEY_FILE = "/data/wolf/cfg/key.pem";
        WOLF_PRIVATE_CERT_FILE = "/data/wolf/cfg/cert.pem";
        # TODO: Restore when Podman works
        # WOLF_DOCKER_SOCKET = "/run/podman/podman.sock";
        WOLF_DOCKER_SOCKET = "/var/run/docker.sock";
      };
      extraOptions = [
        "--network=host"
        "--ipc=host"
        "--device-cgroup-rule=c 13:* rmw"
        "--cap-add=CAP_SYS_PTRACE"
        "--cap-add=CAP_NET_ADMIN"
        "--device=/dev/dri:/dev/dri"
        "--device=/dev/uinput:/dev/uinput"
      ];
    };
    networking.firewall = {
      allowedTCPPorts = [
        47984
        47989
        48010
      ];
      allowedUDPPorts = [
        47999
        47998
        48000
        48010
      ];
      allowedUDPPortRanges = [
        {
          from = 48100;
          to = 48110;
        }
        {
          from = 48200;
          to = 48210;
        }
      ];
    };
  };
}
