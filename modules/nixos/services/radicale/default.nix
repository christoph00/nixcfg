{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.services.radicale;
in {
  options.chr.services.radicale = with types; {
    enable = mkBoolOpt' false;
  };
  config = mkIf cfg.enable {
    services.radicale = {
      enable = true;
      settings = {
        server = {
          hosts = [
            "0.0.0.0:5232"
            "[::]:5232"
          ];
        };
        auth = {
          type = "htpasswd";
          htpasswd_filename = "/nix/persist/radicale/users";
          htpasswd_encryption = "bcrypt";
        };
        storage = {
          filesystem_folder = "/nix/persist/radicale/collections";
        };
      };
      rights = {
        root = {
          user = ".+";
          collection = "";
          permissions = "R";
        };
        principal = {
          user = ".+";
          collection = "{user}";
          permissions = "RW";
        };
        calendars = {
          user = ".+";
          collection = "{user}/[^/]+";
          permissions = "rw";
        };
      };
    };
    services.cloudflared.tunnels."${config.networking.hostName}" = {
      ingress = {
        "cdav.r505.de" = "http://127.0.0.1:5232";
      };
    };
  };
}
