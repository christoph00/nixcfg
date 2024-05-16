{
  options,
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.meta;
  jsonValue = with types; let
    valueType =
      nullOr (oneOf [
        bool
        int
        float
        str
        (lazyAttrsOf valueType)
        (listOf valueType)
      ])
      // {
        description = "JSON value";
        emptyValue.value = {};
      };
  in
    valueType;
in {
  options.chr.meta = mkOption {
    type = jsonValue;
    default = {domain = "example.com";};
  };
  config = {
    warnings =
      lib.optional (!(config.chr.meta.hosts ? ${config.networking.hostName}))
      "no network configuration for ${config.networking.hostName} found in meta.json";

    chr.meta = builtins.fromJSON (builtins.readFile ../../meta.json);
  };
}
