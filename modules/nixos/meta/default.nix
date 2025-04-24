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
    mkIf
    mkMerge
    mkOption
    ;

  cfg = config.internal;

  hostOptions =
    name:
    types.submodule {
      options = {
        ipv4 = mkOption {
          type = types.str;
          default = "0.0.0.0";
          example = "10.10.1.1";
        };

        pubkey = mkOption {
          type = types.str;
          default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDiemTJHxx3emXiY9Ya8mdfLOU3Nl9AFKcZJfdnV9kU7"; # master key
          description = "Host Public Key";
        };

        zone = mkOption {
          type = types.enum [
            "home"
            "cloud"
          ];
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

        description = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Eine Beschreibung des Hosts.";
        };

        macAddress = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Die primäre MAC-Adresse des Hosts.";
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
          description = "Die CPU-Architektur des Hosts.";
        };

        id = mkOption {
          type = types.int;
          description = "Eindeutige numerische ID des Hosts.";
          example = 1;
        };
      };
    };

  hasRole = role: (builtins.elem role cfg.roles);

  # --- WireGuard P2P IP Generation ---
  # Helper function to convert an integer offset within 10.87.0.0/16 to an IP string
  intOffsetToIpString =
    offset:
    let
      baseIpInt = (10 * 256 + 87) * 65536; # 10.87.0.0
      ipInt = baseIpInt + offset;
      o1 = builtins.div ipInt 16777216; # 256^3
      o2 = builtins.div (ipInt - o1 * 16777216) 65536; # 256^2
      o3 = builtins.div (ipInt - o1 * 16777216 - o2 * 65536) 256;
      o4 = ipInt - o1 * 16777216 - o2 * 65536 - o3 * 256;
    in
    "${toString o1}.${toString o2}.${toString o3}.${toString o4}";

  # Hosts, für die P2P-Verbindungen generiert werden sollen
  p2pHostNames = [
    "lsrv"
    "oca"
    "oc1"
    "oc2"
    "star"
    "tower"
  ];

  # Filtered meta data for relevant hosts
  p2pMeta = lib.filterAttrs (name: _: builtins.elem name p2pHostNames) cfg.meta;

  # Sorted list of relevant host names
  sortedP2pHostNames = lib.sort lib.lessThan (lib.attrNames p2pMeta);

  # Generate all unique pairs (hostA, hostB) where hostA < hostB alphabetically
  hostPairs = lib.flatten (
    lib.imap0 (
      idxA: hostA:
      lib.imap0 (idxB: hostB: if idxA < idxB then { inherit hostA hostB; } else null) sortedP2pHostNames
    ) sortedP2pHostNames
  );

  # Assign an index and calculate IPs for each pair
  pairConfigs = lib.imap0 (
    k: pair:
    let
      subnetOffset = k * 4; # Each pair gets a /30 (4 addresses)
      ipA = intOffsetToIpString (subnetOffset + 1); # First usable IP
      ipB = intOffsetToIpString (subnetOffset + 2); # Second usable IP
    in
    {
      hostA = pair.hostA;
      hostB = pair.hostB;
      ipA = ipA;
      ipB = ipB;
      subnetIndex = k;
    }
  ) (lib.filter (x: x != null) hostPairs);

  # Build the final structure accessible via internal.wireguardP2P.<hostA>.<hostB>
  wireguardP2PStructure = lib.foldl (
    acc: pairConfig:
    let
      hostA = pairConfig.hostA;
      hostB = pairConfig.hostB;
      peerInfoA = {
        localIP = pairConfig.ipA;
        remoteIP = pairConfig.ipB;
        subnetIndex = pairConfig.subnetIndex;
      };
      peerInfoB = {
        localIP = pairConfig.ipB;
        remoteIP = pairConfig.ipA;
        subnetIndex = pairConfig.subnetIndex;
      };
    in
    acc
    // {
      ${hostA} = (acc.${hostA} or { }) // {
        ${hostB} = peerInfoA;
      };
      ${hostB} = (acc.${hostB} or { }) // {
        ${hostA} = peerInfoB;
      };
    }
  ) { } pairConfigs;
  # --- End WireGuard P2P IP Generation ---

in
{
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

    isBootstrap = mkOption {
      type = types.bool;
      default = false;
    };

    # Structure containing calculated WireGuard P2P IPs for specific hosts
    # Access via config.internal.wireguardP2P.<hostA>.<hostB>.localIP etc.
    wireguardP2P = mkOption {
      type = types.attrsOf (
        types.attrsOf (
          types.submodule {
            options = {
              localIP = mkOption { type = types.str; };
              remoteIP = mkOption { type = types.str; };
              subnetIndex = mkOption { type = types.int; };
            };
          }
        )
      );
      internal = true;
      readOnly = true; # Calculated value
      default = wireguardP2PStructure;
      description = "Berechnete WireGuard P2P-Verbindungsinformationen für definierte Hosts.";
    };
  };

}
