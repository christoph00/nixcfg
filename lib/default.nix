{ inputs, flake, ... }:
with inputs.nixpkgs;
let
  inherit (lib)
    mkOption
    types
    mkDefault
    attrNames
    mkIf
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
      extra-config ? { },
    }:
    assert assertMsg (port != "" && port != null) "port cannot be empty";
    assert assertMsg (host != "") "host cannot be empty";
    extra-config
    // {
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

  allHostsList = attrNames flake.nixosConfigurations;

}
