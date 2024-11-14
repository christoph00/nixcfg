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

in
{
  options.interal = with types; {
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
        "headless"
      ]);
      default = [ ];
      description = "Liste der aktiven Systemrollen";
    };

    hasRole = role: (builtins.elem role cfg.roles);

    isSmartHome = mkOption {
      type = types.bool;
      default = cfg.hasRole "smart-home";
    };

    isRouter = mkOption {
      type = types.bool;
      default = cfg.hasRole "router";
    };

    isGaming = mkOption {
      type = types.bool;
      default = cfg.hasRole "gaming";
    };

    isMedia = mkOption {
      type = types.bool;
      default = cfg.hasRole "media";
    };

    isHeadless = mkOption {
      type = types.bool;
      default = cfg.hasRole "headless";
    };

    isGameStream = mkOption {
      type = types.bool;
      default = cfg.hasRole "gamestream";
    };

    requiresGUI = mkOption {
      type = types.bool;
      default = cfg.isGaming || cfg.hasRole "gamestream" || cfg.isDesktop;
    };

  };

}
