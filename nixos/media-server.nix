{
  pkgs,
  config,
  lib,
  ...
}: {


  environment.persistence."/nix/persist" = {
    directories = [
      {
        directory = "/var/lib/jellyfin";
        inherit (config.services.jellyfin) user group;
      }
    ];
  };

  environment.systemPackages = with pkgs; [
    rclone
    git
    tmux
    wget
    btrfs-progs
    unrar
    bottom
    systemd-rest
    xplr
    unzip
    media-sort
    ffmpeg-full
  ];

  users.users.jellyfin.extraGroups = ["media"];
  services.jellyfin = {
    enable = true;
    openFirewall = false;
  };

    systemd.services.mount-jellyfin-media = {
    description = "Mount Jellyfin Media";
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "notify";
      ExecStartPre = "/run/current-system/sw/bin/mkdir -p /var/lib/jellyfin/media";
      ExecStart = "${pkgs.rclone}/bin/rclone mount --config ${config.age.secrets.rclone-conf.path} --vfs-cache-mode full --allow-other --vfs-cache-max-size 500M --no-modtime --gid 900 --umask 022 NDCRYPT: /var/lib/jellyfin/media";
      ExecStop = "${pkgs.fuse}/bin/fusermount -u /var/lib/jellyfin/media";
      Restart = "always";
      RestartSec = "20";
    };
  };


}
