{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.services.media;
in {
  options.chr.services.media = with types; {
    enable = mkBoolOpt false "Enable Media Service.";
  };
  config = mkIf cfg.enable {
    environment.persistence."${config.chr.system.persist.stateDir}" = {
      directories = [
        {
          directory = "/var/lib/jellyfin";
          inherit (config.services.jellyfin) user group;
        }
        {
          directory = "/var/lib/sabnzbd";
          inherit (config.services.sabnzbd) user group;
        }
      ];
    };

    networking.firewall.allowedTCPPorts = [8080 8096];

    environment.systemPackages = with pkgs; [
      rclone
      git
      tmux
      wget
      btrfs-progs
      unrar

      unzip
    ];

    users.users.sabnzbd.extraGroups = ["media"];
    users.users.jellyfin.extraGroups = ["media"];
    services.jellyfin = {
      enable = true;
      openFirewall = false;
    };
    services.sabnzbd = {
      enable = true;
      group = "media";
    };

    systemd.services.sabnzbd.serviceConfig.UMask = lib.mkForce "002";
  };
}
