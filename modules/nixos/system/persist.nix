{
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  config = {
    # mkIF options,...
    environment.persistence."/nix/persist" = {
      hideMounts = true;
      directories = [
        "/var/lib/containers"
        "/var/log"
        "/var/db/sudo"
        "/var/lib/bluetooth"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        # if Networkmanager
        "/etc/NetworkManager/system-connections"
        # if sound
        "/var/lib/pipewire"

        # if tailscale
        "/var/cache/tailscale"
        "/var/lib/tailscale"
      ];
      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
        "/etc/nix/id_rsa"
      ];
    };
  };
}
