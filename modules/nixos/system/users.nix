{
  self,
  self',
  lib,
  config,
  pkgs,
  inputs',
  inputs,
  ...
}: {
  security.sudo.wheelNeedsPassword = false;
  programs.fuse.userAllowOther = true;
  users.mutableUsers = false;
  users.groups.media.gid = 900;

  users.users."${config.nos.mainUser}" = {
    description = "${config.nos.mainUser}";
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
    passwordFile = config.age.secrets.user-password.path;
  };

  users.users.root.passwordFile = config.age.secrets.user-password.path;

  home-manager = lib.mkIf config.nos.enableHomeManager {
    verbose = true;
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "old";
    extraSpecialArgs = {
      inherit inputs self inputs' self';
    };
    users = {
      ${config.nos.mainUser} = "${self}/modules/nixos";
    };
  };
}
