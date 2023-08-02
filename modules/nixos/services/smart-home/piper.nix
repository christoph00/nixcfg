{...}: {
  virtualisation.oci-containers = {
    backend = "podman";
    containers.wyoming-piper = {
      volumes = ["/nix/persist/hass/piper:/data"];
      image = "docker.io/rhasspy/wyoming-piper:latest";
      extraOptions = [
        "--network=host"
      ];
      cmd = [
        "--voice"
        "de-kerstin-low"
        "--uri"
        "'tcp://0.0.0.0:10200'"
      ];
    };
  };
}
