{
  config,
  pkgs,
  ...
}: {
  systemd.services.rclone-private = {
    wantedBy = ["multi-user.target"];
    after = ["network-online.target"];
    serviceConfig = {
      ExecStart = "${pkgs.rclone}/bin/rclone serve webdav NDCRYPT: --config ${config.age.secrets.rclone-conf.path} --addr unix:///run/rclone/ndcrypt.sock";
      Group = "caddy";
      RuntimeDirectory = "rclone-nd";
      RuntimeDirectoryMode = "0770";
      UMask = "0002";
    };
  };

  # services.caddy.virtualHosts."dav.r505.de" = {
  #   extraConfig = ''
  #     basicauth {
  #       cc JDJhJDE0JDAvOVAzSzFMVlNsM1BjMFhPUS5lby5IMWdDcVd5MVlqdDZEN3JSMXpxQTQzTkZleU9aMU8y
  #     }
  #     reverse_proxy unix/run/rclone/ndcrypt.sock
  #     encode gzip
  #   '';
  # };
}
