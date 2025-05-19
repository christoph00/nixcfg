{ inputs, flake, ... }:
with inputs.nixpkgs;
let
  inherit (lib)
    mkOption
    types
    mkDefault
    attrNames
    getAttr
    ;
in
rec {
  mkOpt = type: default: mkOption { inherit type default; };
  mkBoolOpt = default: mkOpt types.bool default;
  mkIntOpt = default: mkOpt types.int default;
  mkStrOpt = default: mkOpt types.str default;

  enabled = {
    enable = true;
  };

  disabled = {
    enable = false;
  };

  default = {
    enable = mkDefault true;
  };

  nodefault = {
    enable = mkDefault false;
  };

  create-proxy =
    {
      port ? null,
      host ? "127.0.0.1",
      proxy-web-sockets ? false,
      kTLS ? true,
      acmeHost ? "r505.de",
      aliases ? [ ],
      extra-config ? { },
    }:
    extra-config
    // {
      inherit kTLS;
      useACMEHost = acmeHost;
      serverAlias = aliases;
      locations = (extra-config.locations or { }) // {
        "/" = (extra-config.locations."/" or { }) // {
          proxyPass = "http://${host}${if port != null then ":${builtins.toString port}" else ""}";

          proxyWebsockets = proxy-web-sockets;
        };
      };
    };

  mkSecret =
    {
      file,
      owner ? "root",
      group ? "root",
      mode ? "400",
      ...
    }:
    {
      file = "${flake}/secrets/${file}.age";
      inherit owner group mode;
    };

  toList = attrs: (builtins.map (key: getAttr key attrs) (attrNames attrs));

  allHostsList = attrNames flake.nixosConfigurations;

  allSystems = toList flake.nixosConfigurations;

  allMicroVMS = builtins.filter (
    x: ((builtins.hasAttr "microvm" x.config.virt.microvm) && (x.config.virt.microvm.isGuest == true))
  ) allSystems;

}
