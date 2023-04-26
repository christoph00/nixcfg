{
  pkgs,
  config,
  lib,
  ...
}: {
  services.home-assistant.config.recorder.db_url = "postgresql://@/ha";
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
    extraPlugins = with pkgs.postgresql15Packages; [
      timescaledb
    ];
    ensureDatabases = ["ha"];
    dataDir = "/nix/persist/postgresql/${config.services.postgresql.package.psqlSchema}";
    ensureUsers = [
      {
        name = "ha";
        ensurePermissions."DATABASE ha" = "ALL PRIVILEGES";
      }
    ];
  };
}
