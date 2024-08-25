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
  cfg = config.internal.services.sshd;
  public-keys = (import ../../../../ssh-public-keys.nix);
in
{

  config = {
    services.openssh = {
      enable = true;

      # ragenix uses this to determine which ssh keys to use for decryption
      hostKeys = mkIf config.internal.system.state.enable [
        {
          path = "/mnt/state/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
    };

  };
}
