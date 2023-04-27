{
  pkgs,
  config,
  lib,
  ...
}: {
  systemd.services.home-assistant = {
    requires = ["postgresql.service"];
    after = ["postgresql.service"];
  };
  services.home-assistant.config.recorder.db_url = "postgresql://@/ha";
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
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
