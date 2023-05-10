{
  config,
  pkgs,
  lib,
  ...
}: {
  system.stateVersion = "22.11";
  hardware.enableRedistributableFirmware = true;

  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_xanmod_latest;
  boot.extraModulePackages = with config.boot.kernelPackages; [acpi_call];

  boot.kernel.sysctl = {
    "max_user_watches" = 524288;
    "kernel.dmesg_restrict" = true;
    "kernel.unprivileged_bpf_disabled" = true;
    "kernel.unprivileged_userns_clone" = 1;
    "net.core.bpf_jit_harden" = true;
  };

  i18n.defaultLocale = "de_DE.UTF-8";
  i18n.extraLocaleSettings = lib.mkDefault {
    LC_TIME = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
  };

  time.timeZone = "Europe/Berlin";

  nix = {
    settings = {
      substituters = [
        # "https://hyprland.cachix.org"
        # "https://nix-community.cachix.org"
        # "https://chr.cachix.org"
        "https://cache.garnix.io"
      ];
      trusted-public-keys = [
        # "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        # "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        # "chr.cachix.org-1:8Z0vNVd8hK8lVU53Y26GHDNc6gv3eFzBNwSYOcUvsgA="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      ];
      trusted-users = ["root" "@wheel"];
      auto-optimise-store = lib.mkDefault true;
      warn-dirty = false;
    };
    package = pkgs.nixUnstable;
    gc = {
      automatic = true;
      dates = "weekly";
    };
  };

  # TODO: Check if Home Net
  #networking.domain = "lan.net.r505.de";

  networking.useHostResolvConf = false;
  services.resolved = {
    enable = lib.mkDefault true;
    dnssec = "false";
    llmnr = "true";
    extraConfig = ''
      DNSStubListenerExtra=[::1]:53
    '';
  };

  security.sudo.wheelNeedsPassword = false;

  programs.fuse.userAllowOther = true;

  users.mutableUsers = false;

  users.groups.media.gid = 900;

  age.secrets.christoph-password.file = ../secrets/christoph-password.age;

  programs.command-not-found.enable = false;
  programs.fish.enable = true;

  users.users.christoph = {
    description = "Christoph";
    isNormalUser = true;
    createHome = true;
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "input"
      "uinput"
      "dbus"
      "adbusers"
      "lp"
      "scanner"
      "sound"
      "media"
      "podman"
      "adbusers"
    ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKBCs+VL1FAip0JZ2wWnop9lUZHcs30mibUwwrMJpfAX christoph@air13"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICRlMoMsGWPbUR9nC0XavzLmcolpF8hRbvQYALJQNMg8 christoph@tower"
    ];
    passwordFile = config.age.secrets.christoph-password.path;
  };

  users.users.root.passwordFile = config.age.secrets.christoph-password.path;

  services.openssh = {
    enable = true;
    hostKeys = [
      {
        path = "/nix/persist/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };
  programs.mosh.enable = true;

  environment.systemPackages = [
    pkgs.git
    pkgs.killall
    pkgs.dnsutils
    pkgs.htop
  ];

  environment.shellAliases = {
    nrb = "nixos-rebuild --flake github:christoph00/nixcfg --use-remote-sudo boot";
    nrs = "nixos-rebuild --flake github:christoph00/nixcfg --use-remote-sudo switch";
  };
  environment.persistence."/nix/persist" = {
    hideMounts = true;
    directories = [
      "/var/lib/containers"
      "/var/lib/tailscale"
      "/var/lib/netdata"
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
      #"/etc/ssh/ssh_host_ed25519_key"
      #"/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/nix/id_rsa"
    ];
  };

  # services.prometheus.exporters.node = {
  #   enable = true;
  #   enabledCollectors = ["systemd"];
  #   port = 9002;
  # };
}
