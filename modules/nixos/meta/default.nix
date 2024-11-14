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

  hasRole = role: (builtins.elem role cfg.roles);

in
{
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

  };

}
