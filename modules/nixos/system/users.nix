{
  lib,
  config,
  pkgs,
  ...
}: {
  security.sudo.wheelNeedsPassword = false;

  users.users.christoph = {
    description = "Christoph";
    isNormalUser = true;
    createHome = true;
    shell = pkgs.bash;
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
}
