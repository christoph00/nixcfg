{
  options,
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    types
    mkOption
    ;

  cfg = config.internal;

  hostOptions =
    name:
    types.submodule {
      options = {

        pubkey = mkOption {
          type = types.str;
          default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDiemTJHxx3emXiY9Ya8mdfLOU3Nl9AFKcZJfdnV9kU7"; # master key
        };

        zone = mkOption {
          type = types.enum [
            "home"
            "oracle"
            "cloud"
            "external"
          ];
          default = "home";
        };

        hostname = mkOption {
          type = types.str;
          default = name;
        };

        description = mkOption {
          type = types.nullOr types.str;
          default = null;
        };

        macAddress = mkOption {
          type = types.nullOr types.str;
          default = null;
          example = "00:11:22:33:44:55";
        };

        architecture = mkOption {
          type = types.nullOr (
            types.enum [
              "x86_64"
              "aarch64"
            ]
          );
          default = null;
        };

        id = mkOption {
          type = types.int;
          example = 1;
        };
        roles = mkOption {
          type = types.listOf (enum [
            "smart-home"
            "router"
            "gamestream"
            "gaming"
            "media"
            "webserver"
            "development"
            "nas"
            "headless-desktop"
          ]);
          default = [ ];
        };

      };
    };

  hasRole = role: (builtins.elem role cfg.self.roles);

in
{
  imports = [ ./config.nix ];

  options.internal = {

    hosts = mkOption {
      type = types.attrsOf (name: hostOptions name);
      default = { };
    };

    self = mkOption {
      type = types.attrs;
      internal = true;
      default = config.internal.hosts.${config.networking.hostName};
    };
    isSmartHome = mkOption {
      type = types.bool;
      default = hasRole "smart-home";
    };

    isRouter = mkOption {
      type = types.bool;
      default = hasRole "router";
    };

    isGaming = mkOption {
      type = types.bool;
      default = hasRole "gaming";
    };

    isMedia = mkOption {
      type = types.bool;
      default = hasRole "media";
    };

    isHeadlessDesktop = mkOption {
      type = types.bool;
      default = hasRole "headless-desktop";
    };

    isGameStream = mkOption {
      type = types.bool;
      default = hasRole "gamestream";
    };

    isBootstrap = mkOption {
      type = types.bool;
      default = false;
    };

  };

}
