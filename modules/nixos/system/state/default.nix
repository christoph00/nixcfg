{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib,
  # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs,
  # You also have access to your flake's inputs.
  inputs,
  # Additional metadata is provided by Snowfall Lib.
  namespace,
  # The namespace used for your flake, defaulting to "internal" if not set.
  system,
  # The system architecture for this host (eg. `x86_64-linux`).
  target,
  # The Snowfall Lib target for this system (eg. `x86_64-iso`).
  format,
  # A normalized name for the system target (eg. `iso`).
  virtual,
  # A boolean to determine whether this system is a virtual target using nixos-generators.
  systems, # An attribute map of your defined hosts.

  # All other arguments come from the module system.
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
with lib.internal;

let
  cfg = config.internal.system.state;
in
{
  options.internal.system.state = with types; {
    enable = mkBoolOpt' true;

    stateDir = mkStrOpt' "/mnt/state";

    directories = mkOpt' (listOf anything) [ ];
    files = mkOpt' (listOf anything) [ ];
  };

  config = mkIf cfg.enable {
    users.mutableUsers = false;
    programs.fuse.userAllowOther = true;
    fileSystems."${cfg.stateDir}".neededForBoot = true;

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
        ] ++ cfg.files;
        directories = [
          "/var/lib/bluetooth"
          "/var/lib/fprint"
          "/var/lib/fwupd"
          "/var/lib/power-profiles-daemon"
          "/var/lib/systemd/coredump"
          "/var/lib/systemd/rfkill"
          "/var/lib/systemd/timers"
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
