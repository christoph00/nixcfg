{
  pkgs,
  config,
  lib,
  ...
}:
let
  c = rec {
    rcloneConfigFile = config.age.secrets.rclone-conf.path;


    rclone-lim = pkgs.writeScriptBin "rclone-lim" ''
      #!/usr/bin/env bash
      ${pkgs.rclone}/bin/rclone --config "${rcloneConfigFile}" "''${@}"
    '';

    rclone-lim-mount = readonly: (pkgs.writeScriptBin "rclone-lim-mount" ''
      #!/usr/bin/env bash
      ${pkgs.rclone}/bin/rclone \
        --config ${rcloneConfigFile} \
        --fast-list \
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
        --fuse-flag=sync_read \
        --fuse-flag=auto_cache \
        --gid 600 \
        ${if readonly then "--read-only \\" else "\\"}
        --umask=022 \
        -v \
        mount ''${@}
    '');

  };
  in
 {


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


systemd.services.mount-ndcrypt = {
    description = "RCLONE MEDIA";
    path = with pkgs; [ fuse bash ];
    serviceConfig = {
      Type = "simple";
      ExecStartPre = [
        "-${pkgs.fuse}/bin/fusermount -uz /var/lib/jellyfin/media"
        "${pkgs.coreutils}/bin/mkdir -p /var/lib/jellyfin/media"
      ];
      ExecStart = "${c.rclone-lim-mount false}/bin/rclone-lim-mount --allow-other NDCRYPT:media /var/lib/jellyfin/media";
      ExecStop = "${pkgs.fuse}/bin/fusermount -uz /var/lib/jellyfin/media";
      Restart = "on-failure";
    };
    startLimitIntervalSec = 60;
    startLimitBurst = 3;
    wantedBy = [ "default.target" ];
  }

}
