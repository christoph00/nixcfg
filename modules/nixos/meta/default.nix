{ lib, config, ... }:

let
  inherit (lib) types;

  validRoles = [
    "webserver"
    "development"
    "nas"
    "desktop"
    "headless-desktop"
    "game-stream"
    "gaming"
    "smarthome"
  ];

  hostOptions =
    { name, ... }:
    {
      options = {
        id = lib.mkOption {
          type = types.addCheck types.int (id: id >= 2 && id <= 254) "Host ID must be between 2-254";
          description = "Unique numerical identifier";
          example = 210;
        };

        pubkey = lib.mkOption {
          type = types.nullOr types.nonEmptyStr;
          default = null;
          description = "SSH public key";
          example = "ssh-ed25519 AAAAC3Nza...";
        };

        wgPubkey = lib.mkOption {
          type = types.nullOr types.nonEmptyStr;
          default = null;
          description = "WireGuard public key";
        };

        wgPrivkey = lib.mkOption {
          type = types.nullOr types.nonEmptyStr;
          default = "${config.age.secrets.wgPrivkey.path}";
          description = "WireGuard private key";
        };

        zone = lib.mkOption {
          type = types.enum [
            "oracle"
            "home"
            "cloud"
            "external"
          ];
          default = "external";
          description = "Deployment zone";
        };

        architecture = lib.mkOption {
          type = types.enum [
            "x86_64"
            "aarch64"
          ];
          description = "CPU architecture";
        };

        roles = lib.mkOption {
          type = types.listOf (types.enum validRoles);
          default = [ ];
          description = "Assigned roles";
        };

        net = lib.mkOption {
          type = types.submodule {
            options = {
              lan = lib.mkOption {
                type = types.either (types.strMatching "^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$") (types.enum [ "dhcp" ]);
                description = "LAN IP configuration";
              };

              wan = lib.mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "Public IP address";
              };

              vpn = lib.mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "VPN IP address";
              };
            };
          };
          default = { };
          description = "Network configuration";
        };
      };
    };

in
{
  imports = [ ./config.nix ];
  options.internal = {
    hosts = lib.mkOption {
      type = types.attrsOf (types.submodule hostOptions);
      default = { };
      description = "Managed hosts registry";
    };

    subnets = {
      home = lib.mkOption { type = lib.types.str; };
      oracle = lib.mkOption { type = lib.types.str; };
      vpn = lib.mkOption { type = lib.types.str; };
    };

    thisHost = lib.mkOption {
      type = types.str;
      default = config.networking.hostName;
      description = "Current host identifier";
    };

    currentHost = lib.mkOption {
      type = types.submodule hostOptions;
      default = { };
      description = "Current host configuration";
    };

    hasRole = lib.mkOption {
      type = types.functionTo types.bool;
      default = role: builtins.elem role config.internal.currentHost.roles;
      description = "Role presence checker";
      readOnly = true;
    };
  };

  config = {
    internal.currentHost = lib.mkMerge [
      (lib.mkIf (
        config.internal.hosts ? ${config.internal.thisHost}
      ) config.internal.hosts.${config.internal.thisHost})
      {
        roles = [ ];
        net = {
          lan = null;
          wan = null;
          vpn = null;
        };
      }
    ];

    assertions = [
      {
        assertion = config.internal.hosts ? ${config.internal.thisHost};
        message = "Host '${config.internal.thisHost}' not defined!";
      }
      {
        assertion = lib.all (role: builtins.elem role validRoles) config.internal.currentHost.roles;
        message = "Invalid role detected in host config";
      }
    ];
  };
}
