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
      ExecStart = ''
        ${pkgs.rclone}/bin/rclone mount --config ${config.age.secrets.rclone-conf.path} \
        --allow-other \
        --no-modtime \
        --gid 900 \
        --umask 022 \
        --vfs-read-chunk-size=64M \
        --vfs-read-chunk-size-limit=2048M \
        --vfs-cache-mode writes \
        --buffer-size=128M \
        --max-read-ahead=256M \
        --poll-interval=1m \
        --dir-cache-time=168h \
        --timeout=10m \
        --transfers=16 \
        --checkers=12 \
        NDCRYPT:media /var/lib/jellyfin/media'';
      ExecStop = "fusermount -u /var/lib/jellyfin/media";
      Restart = "always";
      RestartSec = "20";
      Environment = [
        "PATH=/run/wrappers/bin/:$PATH"
      ];
    };
  };
}
