{
  config,
  lib,
  ...
}: let
  cfg = config.persist;
in {
  options.persist = {
    enable =
      lib.mkEnableOption "Persist" {
      };
  };

  config.persistence =
    lib.mkIf cfg.enable {
    };
}
