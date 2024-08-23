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
  cfg = config.internal.system.disk;
in
{
  options.internal.system.disk = with types; {
    disk = mkStrOpt' null; # nvme0n1
    espSize = mkStrOpt' "1G";
    swapSize = mkStrOpt' "1G";
    layout = mkStrOpt' "bcachefs";
  };

  config = (
    mkMerge [
      (mkIf (cfg.layout == "luks-xfs") (
        import ./layouts/luks-xfs.nix { inherit (cfg) disk espSize swapSize; }
      ))
      (mkIf (cfg.layout == "luks-btrfs") (
        import ./layouts/luks-btrfs.nix { inherit (cfg) disk espSize swapSize; }
      ))
      (mkIf (cfg.layout == "bcachefs") (
        import ./layouts/bcachefs.nix { inherit (cfg) disk espSize swapSize; }
      ))
    ]
  );
}
