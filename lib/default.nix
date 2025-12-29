{ inputs, flake, ... }:
with inputs.nixpkgs;
let
  inherit (lib)
    mkOption
    types
    mkDefault
    attrNames
    getAttr
    concatStringsSep
    mapAttrsToList
    optionalString
    mapAttrs
    filterAttrs
    ;
in
rec {
  mkOpt = type: default: mkOption { inherit type default; };
  mkBoolOpt = default: mkOpt types.bool default;
  mkIntOpt = default: mkOpt types.int default;
  mkStrOpt = default: mkOpt types.str default;
  mkStrOptNull = mkOpt (types.nullOr types.str) null;

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

  create-caddy-proxy =
    {
      port ? null,
      host ? "127.0.0.1",
      proxy-web-sockets ? false,
      acmeHost ? "r505.de",
      extraHeaders ? { },
      extraConfig ? "",
    }:
    {
      useACMEHost = acmeHost;
      extraConfig = ''
        reverse_proxy ${host}${
          if port != null then ":${builtins.toString port}" else ""
        }${lib.optionalString proxy-web-sockets " {
          header_up Connection {>Connection}
          header_up Upgrade {>Upgrade}
        }"}${
          lib.optionalString (extraHeaders != { }) (
            lib.concatStringsSep "\n" (
              lib.mapAttrsToList (key: value: "          header_up ${key} \"${value}\"") extraHeaders
            )
          )
        }${lib.optionalString (extraConfig != "") "\n${extraConfig}"}
      '';
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

  toEnvValue = env: if isList env then concatStringsSep ":" (map toString env) else toString env;

  toEnvExport =
    vars:
    (concatStringsSep "\n" (
      mapAttrsToList (name: value: "export ${name}=\"${toEnvValue value}\"") vars
    ));

}
