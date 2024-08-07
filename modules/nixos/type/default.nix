{
  options,
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib) mDoc types listOf;
  inherit (lib.${namespace}) mkOpt mkBoolOpt;
  cfg = config.chr.type;
in {
  options.${namespace} = with types; {
    type = mkOption {
      type = enum [
        "laptop"
        "desktop"
        "server"
        "vm"
        "microvm"
        "bootstrap"
      ];
    };
    isMicroVM = mkBoolOpt (config.${namespace}.type == "microvm") "Whether or not this is a microvm.";
    isLaptop = mkBoolOpt (config.${namespace}.type == "laptop") "Whether or not this is a laptop.";
    isDesktop = mkBoolOpt (config.${namespace}.type == "desktop") "Whether or not this is a desktop.";
    isServer = mkBoolOpt (config.${namespace}.type == "server") "Whether or not this is a server.";
  };
}