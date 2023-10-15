{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.type;
in {
  options.chr.type = mkOption {
    type = types.enum ["laptop" "desktop" "server" "vm"];
  };
}
