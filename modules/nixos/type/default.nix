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
  options.chr = with types; {
    type = mkOption {
      type = enum ["laptop" "desktop" "server" "vm" "microvm" "bootstrap"];
    };
    isMicroVM = mkBoolOpt (config.chr.type == "microvm") "Whether or not this is a microvm.";
  };
}
