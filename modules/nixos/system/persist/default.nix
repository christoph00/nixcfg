{
  options,
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
with lib.chr;
let
  cfg = config.chr.system.persist;
in
{
  imports = [ inputs.impermanence.nixosModules.impermanence ];
  options.chr.system.persist = with types; {
    enable = mkOpt types.bool config.chr.system.filesystem.persist "Whether to persist.";
    stateDir = mkOpt (types.nullOr types.str) "/nix/persist" "The State Dir.";
  };

  config = mkIf cfg.enable {
    chr.system.ssh.hostKeyDir = "${cfg.stateDir}/etc/ssh";

    environment.persistence."${cfg.stateDir}" = {
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
        {
          directory = "/var/lib/private";
          mode = "0700";
        }
      ];
    };

    boot.initrd.systemd.services.rollback = lib.mkIf (!config.chr.system.filesystem.rootOnTmpfs) {
      description = "Rollback BTRFS root subvolume to a pristine state";
      wantedBy = [ "initrd.target" ];
      before = [ "sysroot.mount" ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = ''
        mkdir -p /mnt

        mount -t btrfs ${config.chr.system.filesystem.mainDisk} /mnt

        btrfs subvolume list -o /mnt/@root |
          cut -f9 -d' ' |
          while read subvolume; do
            echo "deleting /$subvolume subvolume..."
            btrfs subvolume delete "/mnt/$subvolume"
          done &&
          echo "deleting @root subvolume..." &&
          btrfs subvolume delete /mnt/@root

        echo "restoring blank @root subvolume..."
        btrfs subvolume snapshot /mnt/@root-blank /mnt/@root

        umount /mnt
      '';
    };
  };
}
