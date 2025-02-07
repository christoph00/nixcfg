{ options, config, lib, pkgs, ... }:

let
  inherit (lib) types mkIf mkMerge mkOption;

  cfg = config.internal;

  hostOptions = name:
    types.submodule {
      options = {
        ipv4 = mkOption {
          type = types.str;
          default = "0.0.0.0";
          example = "10.10.1.1";
        };

        pubkey = mkOption {
          type = types.str;
          default =
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDiemTJHxx3emXiY9Ya8mdfLOU3Nl9AFKcZJfdnV9kU7"; # master key
          description = "Host Public Key";
        };

        zone = mkOption {
          type = types.enum [ "home" "cloud" ];
          default = "home";
        };

        wireguardIP = mkOption {
          type = types.nullOr types.str;
          default = null;
          example = "10.100.0.2";
        };

        hostname = mkOption {
          type = types.str;
          default = name;
        };
      };
    };

  hasRole = role: (builtins.elem role cfg.roles);

in {
  imports = [ ./meta.nix ];

  options.internal = with types; {
    # Liste der aktiven Rollen
    roles = mkOption {
      type = listOf (enum [
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
      description = "Liste der aktiven Systemrollen";
    };

    meta = mkOption {
      type = types.attrsOf (name: hostOptions name);
      description = "Metadaten aller bekannten Systeme";
      default = { };
    };

    self = mkOption {
      type = types.attrs;
      internal = true;
      default = config.internal.meta.${config.networking.hostName};
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

    requiresGUI = mkOption {
      type = types.bool;
      default = isGaming || hasRole "gamestream" || isDesktop;
    };

  };

}
