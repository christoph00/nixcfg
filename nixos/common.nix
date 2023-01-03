{
  config,
  pkgs,
  lib,
  ...
}: {
  system.stateVersion = "22.11";
  hardware.enableRedistributableFirmware = true;

  # TODO: Check if Home Net
  networking.domain = "lan.net.r505.de";

  systemd.network.networks = {
    lan = {
      DHCP = "yes";
      matchConfig.Name = "en*";
    };
  };

programs.fuse.userAllowOther = true;

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
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ8DAhxI8pTuC6L4UucApXzuJaDNa+qqqn+H++h5f7QH christoph@air13win"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM7WLYIiZhnutMwzJx49O4i5QV2S4LndBeKeFJ914Zat christoph@air13"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII1mNuDc7hH54fzRYz8ybmO4v0dCdECuGOJN++4TfbuR christoph@WinTower"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICRlMoMsGWPbUR9nC0XavzLmcolpF8hRbvQYALJQNMg8 christoph@nixTower"
    ];
    password = "hallo009";
  };
}
