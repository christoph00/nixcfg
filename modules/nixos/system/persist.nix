{
  config,
  inputs,
  lib,
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

    boot.initrd.systemd.services.rollback = {
      description = "Rollback BTRFS root subvolume to a pristine state";
      wantedBy = [
        "initrd.target"
      ];
      before = [
        "sysroot.mount"
      ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = ''
        mkdir -p /mnt

        mount -o subvol=@root /dev/disk/by-label/NIXOS /mnt

        btrfs subvolume list -o /mnt/root |
          cut -f9 -d' ' |
          while read subvolume; do
            echo "deleting /$subvolume subvolume..."
            btrfs subvolume delete "/mnt/$subvolume"
          done &&
          echo "deleting /root subvolume..." &&
          btrfs subvolume delete /mnt/root

        echo "restoring blank /root subvolume..."
        btrfs subvolume snapshot /mnt/root-blank /mnt/root

        umount /mnt
      '';
    };
  };
}
