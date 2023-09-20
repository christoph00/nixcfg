{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr;
in {
  options.chr.type = mkOption {
    type = types.enum ["laptop" "desktop" "server" "vm"];
  };

  config = mkMerge [
    (mkIf (cfg.type == "server") {
      })

    (mkIf (cfg.type == "desktop") {
      cfg.apps.firefox.enable = true;
    })
  ];
}
