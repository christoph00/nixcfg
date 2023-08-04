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

  systemd.services.sabnzbd.serviceConfig.UMask = lib.mkForce "002";

  users.users.sabnzbd = {
    #isNormalUser = true;
    #isSystemUser = false;
    shell = pkgs.bash;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEtkH/Ux40Ks3hJToweMP+YhCgBrPZNH/4POZZuGCqmH star-sab"
    ];
    extraGroups = ["media"];
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

  environment.persistence."/nix/persist" = {
    directories = [
      {
        directory = "/var/lib/sabnzbd";
        inherit (config.services.sabnzbd) user group;
      }
    ];
  };

  age.secrets.rclone-conf-sab = {
    file = ../secrets/rclone.conf;
    owner = config.services.sabnzbd.user;
  };
}
