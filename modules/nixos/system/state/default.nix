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

  defaultDirectories = [
    "/etc/secureboot"
    "/var/lib/nixos"
    "/var/lib/systemd"
    "/var/log/journal"
    "/var/lib/docker"
    "/var/lib/containers"
    "/var/lib/taiscale"
    "/var/lib/NetworkManager"
  ];
  defaultFiles = [ ];
  defaultUserDirectories = [
    "Desktop"
    "Documents"
    "Downloads"
    "Music"
    "Pictures"
    "Projects"
    "Public"
    "Templates"
    "Videos"
  ];
  defaultUserFiles = [ ];
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
    environment.persistence."${cfg.stateDir}" = {
      hideMounts = true;
      directories = cfg.directories ++ defaultDirectories;
      files = cfg.files ++ defaultFiles;
    };
  };
}
