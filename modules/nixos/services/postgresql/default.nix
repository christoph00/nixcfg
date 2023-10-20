{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.services.postgresql;
in {
  options.chr.services.postgresql = with types; {
    enable = mkBoolOpt config.chr.services.home-assistant.enable "Enable postgresql.";
  };
  config = mkIf cfg.enable {
    services.home-assistant.config.recorder.db_url = "postgresql://hass@/homeassistant";
    services.postgresql = {
      enable = true;
      authentication = ''
        local homeassistant hass ident map=ha
      '';
      identMap = ''
        ha root hass
      '';
      ensureDatabases = ["homeassistant"];
      ensureUsers = [
        {
          name = "hass";
          ensurePermissions = {"DATABASE homeassistant" = "ALL PRIVILEGES";};
        }
      ];
    };
  };
}
