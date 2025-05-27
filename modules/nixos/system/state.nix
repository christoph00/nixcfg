{
  flake,
  inputs,
  lib,
  config,
  ...
}:

# Necessary System State
#
#   /nix
#   /boot
#   /var/lib/nixos
#   /etc/{passwd,group,shadow,gshadow,subuid,subgid}
#     (OR set `users.mutableUsers = false`)
#   /etc/machine-id
#   /var/lib/systemd
#   /var/log/journal
#   /etc/zfs
#     (only if using the zfs file system)
#
# ref: https://nixos.org/manual/nixos/stable/#ch-system-state

with builtins;
with lib;
with flake.lib;

let
  cfg = config.sys.state;
in
{

  imports = [ inputs.preservation.nixosModules.default ];
  options.sys.state = with types; {
    enable = mkBoolOpt true;

    stateDir = mkStrOpt "/mnt/state";

    directories = mkOpt (listOf anything) [ ];
    files = mkOpt (listOf anything) [ ];
  };

  config = mkIf cfg.enable {
    users.mutableUsers = false;
    programs.fuse.userAllowOther = true;
    fileSystems."${cfg.stateDir}".neededForBoot = true;

    age.identityPaths = [ "${cfg.stateDir}/etc/ssh/ssh_host_ed25519_key" ];

    boot.initrd.systemd.suppressedUnits = [ "systemd-machine-id-commit.service" ];
    systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];

    preservation = {
      enable = true;
      preserveAt."${cfg.stateDir}" = {
        files = [
          # auto-generated machine ID
          {
            file = "/etc/machine-id";
            inInitrd = true;
          }
          {
            file = "/var/lib/systemd/random-seed";
            # create a symlink on the volatile volume
            how = "symlink";
            # prepare the preservation early during startup
            inInitrd = true;
          }
          {
            file = "/etc/ssh/ssh_host_ed25519_key.pub";
            mode = "0644";
          }
          {
            file = "/etc/ssh/ssh_host_ed25519_key";
            mode = "0600";
          }
          {
            file = "/etc/ssh/ssh_host_rsa_key.pub";
            mode = "0644";
          }
          {
            file = "/etc/ssh/ssh_host_rsa_key";
            mode = "0600";
          }
        ] ++ cfg.files;
        directories = [
          "/var/lib/bluetooth"
          "/var/lib/fprint"
          "/var/lib/fwupd"
          "/var/lib/power-profiles-daemon"
          "/var/lib/systemd/coredump"
          "/var/lib/systemd/rfkill"
          "/var/lib/systemd/timers"

          "/var/lib/containers"
          {
            directory = "/var/lib/nixos";
            inInitrd = true;
          }
          {
            directory = "/var/log";
            inInitrd = true;
          }
        ] ++ cfg.directories;
      };
    };
  };
}
