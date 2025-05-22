{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkDefault mkForce;
in
{

  environment = {
    systemPackages = [ pkgs.git ];
    variables.NIXPKGS_CONFIG = mkForce "";

  };

  programs.nh = {
    enable = mkDefault true;

    clean = {
      enable = !config.nix.gc.automatic;
      dates = "weekly";
    };
  };

  system.disableInstallerTools = config.programs.nh.enable;
  system.stateVersion = "25.11";

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _: true;
    allowAliases = false;
  };

  nix = {
    package = pkgs.lix;
    gc = {
      automatic = true;
      dates = "Mon *-*-* 04:00";
      options = "--delete-older-than 3d";
    };

    optimise = {
      automatic = true;
      dates = [ "04:41" ];
    };

    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";
    daemonIOSchedPriority = 7;

    settings = {
      min-free = 5 * 1024 * 1024 * 1024;
      max-free = 20 * 1024 * 1024 * 1024;
      use-cgroups = true;
      extra-platforms = config.boot.binfmt.emulatedSystems;
      auto-optimise-store = true;
      allowed-users = [ "@wheel" ];
      trusted-users = [ "@wheel" ];
      max-jobs = "auto";
      sandbox = true;
      system-features = [
        "nixos-test"
        "kvm"
        "recursive-nix"
        "big-parallel"
      ];
      keep-going = true;
      extra-experimental-features = [
        "flakes"

        "nix-command"

        "recursive-nix"

        "ca-derivations"

        "auto-allocate-uids"

        "cgroups"

        "repl-flake"

        "pipe-operator"

        "fetch-closure"

        "dynamic-derivations"
      ];
      use-xdg-base-directories = true;
      keep-derivations = true;
      keep-outputs = true;
      http-connections = 50;
      accept-flake-config = false;

      substituters = [
        "https://chr.cachix.org"
        "https://nyx.chaotic.cx/"
        "https://nix-community.cachix.org"
        "https://cosmic.cachix.org"
        "https://cache.garnix.io"
      ];

      trusted-public-keys = [
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "chr.cachix.org-1:8Z0vNVd8hK8lVU53Y26GHDNc6gv3eFzBNwSYOcUvsgA="
        "nyx.chaotic.cx-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
      ];
    };
  };

}
