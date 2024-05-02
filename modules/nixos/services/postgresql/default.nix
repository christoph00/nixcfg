{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr;
let
  cfg = config.chr.services.postgresql;
in
{
  options.chr.services.postgresql = with types; {
    enable = mkBoolOpt false "Enable postgresql.";
  };
  config = mkIf cfg.enable {
    # services.home-assistant.config.recorder.db_url = "postgresql://hass@/homeassistant";
    services.postgresql = {
      enable = true;
      enableTCPIP = false;
      package = pkgs.postgresql_14;
      dataDir = "${config.chr.system.persist.stateDir}/pgDB/${config.services.postgresql.package.psqlSchema}";
    };
  };
}
