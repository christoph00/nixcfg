{
  pkgs,
  config,
  ...
}: {
  services.home-assistant.config = {
    recorder.db_url = "postgresql://@/hass";
  };
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_13;
    ensureDatabases = ["hass"];
    dataDir = "/nix/persist/postgresql/${config.services.postgresql.package.psqlSchema}";
    ensureUsers = [
      {
        name = "hass";
        ensurePermissions = {
          "DATABASE hass" = "ALL PRIVILEGES";
        };
      }
    ];
  };
}
