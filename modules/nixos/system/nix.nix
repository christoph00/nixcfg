{
  lib,
  pkgs,
  ...
}: {
  system = {
    autoUpgrade.enable = false;
    stateVersion = lib.mkDefault "23.05";
  };
  nix = {
    daemonCPUSchedPolicy = "batch";
    daemonIOSchedClass = "idle";
    daemonIOSchedPriority = 7;
    settings = {
      auto-optimise-store = lib.mkDefault true;
      warn-dirty = false;
      min-free = "${toString (5 * 1024 * 1024 * 1024)}";
      max-free = "${toString (10 * 1024 * 1024 * 1024)}";
      allowed-users = ["@wheel" "nix-builder"];
      trusted-users = ["@wheel" "nix-builder"];
      max-jobs = "auto";
      system-features = ["nixos-tests" "kvm" "recursive-nix" "big-parallel"];
      extra-experimental-features = [
        "flakes"
        "nix-command"
        "recursive-nix"
        "ca-derivations"
      ];
      http-connections = 50;
      accept-flake-config = true;
      builders-use-substitutes = true;
    };
    package = pkgs.nixUnstable;
    gc = {
      automatic = true;
      dates = "daily";
    };
  };
  systemd.services.nix-daemon = {
    environment.TMPDIR = "/nix/tmp";
  };
  systemd.tmpfiles.rules = [
    "d /nix/tmp 0755 root root 1d"
  ];
  programs.command-not-found.enable = false;
}
