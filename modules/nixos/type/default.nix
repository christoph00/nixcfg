{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    types
    mkOption
    ;
  inherit (lib.internal) mkBoolOpt;
in
{
  options.internal = with types; {
    type = mkOption {
      type = enum [
        "laptop"
        "desktop"
        "server"
        "vm"
        "microvm"
        "bootstrap"
        "none"
        "container"
      ];
    };
    isV3 = mkBoolOpt config.internal.isV4 "CPU has v4 features";
    isV4 = mkBoolOpt false "CPU has v3 features";
    isMicroVM = mkBoolOpt (config.internal.type == "microvm") "Whether or not this is a microvm.";
    isVM = mkBoolOpt (config.internal.type == "vm") "Whether or not this is a vm.";
    isBootstrap = mkBoolOpt (config.internal.type == "bootstrap") "Bootsteap";
    isLaptop = mkBoolOpt (config.internal.type == "laptop") "Whether or not this is a laptop.";
    isGraphical = mkBoolOpt (
      config.internal.type == "desktop" || config.internal.type == "laptop"
    ) "Whether or not this is a graphical system.";
    isServer = mkBoolOpt (config.internal.type == "server") "Whether or not this is a server.";
    isHeadless = mkBoolOpt (
      config.internal.type == "server"
      || config.internal.type == "microvm"
      || config.internal.type == "vm"
    ) "Whether or not this is a headless server.";
    isDesktop = mkBoolOpt (config.internal.type == "desktop") "Whether or not this is a desktop.";
    isContainer = mkBoolOpt (config.internal.type == "container") "Whether or not this is a container.";
  };

}
