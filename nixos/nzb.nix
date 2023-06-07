{
  pkgs,
  config,
  lib,
  ...
}: {
  services.sabnzbd = {
    enable = true;
    group = "media";
  };
  users.users.sabnzbd = {
    #isNormalUser = true;
    #isSystemUser = false;
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEtkH/Ux40Ks3hJToweMP+YhCgBrPZNH/4POZZuGCqmH star-sab"
    ];
  };
  environment.systemPackages = with pkgs; [
    rclone
    git
    tmux
    wget
    btrfs-progs
    unrar
    unzip
  ];

  age.secrets.rclone-conf-sab = {
    file = ../secrets/rclone.conf;
    owner = config.services.sabnzbd.user;
  };
}
