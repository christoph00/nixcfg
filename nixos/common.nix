{
  config,
  pkgs,
  lib,
  ...
}: {
  system.stateVersion = "22.11";
  hardware.enableRedistributableFirmware = true;

  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;
  boot.extraModulePackages = with config.boot.kernelPackages; [acpi_call];

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = lib.mkDefault {
    LC_TIME = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
  };

  nix = {
    settings = {
      substituters = [
        "https://hyprland.cachix.org"
        "https://nix-community.cachix.org"
        "https://chr.cachix.org"
      ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "chr.cachix.org-1:8Z0vNVd8hK8lVU53Y26GHDNc6gv3eFzBNwSYOcUvsgA="
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
  networking.domain = "lan.net.r505.de";

  systemd.network.networks = {
    lan = {
      DHCP = "yes";
      matchConfig.Name = "en*";
    };
  };

  programs.fuse.userAllowOther = true;

  users.mutableUsers = false;

   age.secrets.christoph-password.file = ../secrets/christoph-password.age;

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
      "dbus"
      "adbusers"
      "lp"
      "scanner"
      "sound"
    ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKBCs+VL1FAip0JZ2wWnop9lUZHcs30mibUwwrMJpfAX christoph@air13"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICRlMoMsGWPbUR9nC0XavzLmcolpF8hRbvQYALJQNMg8 christoph@nixTower"
    ];
    passwordFile = config.age.secrets.christoph-password.path
  };

  services.openssh = {
    enable = true;
    # Harden
    passwordAuthentication = false;
    permitRootLogin = "no";
    # Automatically remove stale sockets
    extraConfig = ''
      StreamLocalBindUnlink yes
    '';
    # Allow forwarding ports to everywhere
    gatewayPorts = "clientspecified";

    hostKeys = [
      {
        path = "/persist/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };
}
