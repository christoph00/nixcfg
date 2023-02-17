{
  pkgs,
  config,
  lib,
  ...
}: {
  services.home-assistant.config.recorder.db_url = "postgresql://@/hass";
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
    extraPlugins = with pkgs.postgresql15Packages; [
      timescaledb
    ];
    ensureDatabases = ["hass"];
    dataDir = "/nix/persist/postgresql/${config.services.postgresql.package.psqlSchema}";
    ensureUsers = [
      {
        name = "hass";
        ensurePermissions."DATABASE hass" = "ALL PRIVILEGES";
      }
    ];
  };
}
