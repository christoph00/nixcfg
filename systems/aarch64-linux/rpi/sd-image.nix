{ lib, ... }: {
  imports = [
    <nixpkgs/nixos/modules/installer/sd-card/sd-image-aarch64.nix>
    ./hardware.nix
  ];

  boot.supportedFilesystems.zfs = lib.mkForce false;

  services.openssh = {
    enable = true;
    permitRootLogin = "yes";
  };

  networking.useDHCP = true;
  networking.hostName = "rpi";

  users.extraUsers.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAHqEQOgEdi3e8uPWqE2nqzyiKC9Y792C5tNKco6lz4o christoph@tower"

  ];
}
