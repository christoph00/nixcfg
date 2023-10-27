{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.services.odoo;
in {
  options.chr.services.odoo = with types; {
    enable = mkBoolOpt false "Enable odoo Service.";
  };
  config = mkIf cfg.enable {
    services.odoo = {
      enable = true;
      addons = [];
      #domain = "tower.lan.r505.de";
      settings = {
        options = {
          db_user = "odoo";
          db_password = "odoo";
          admin_passwd = "odoo123";
        };
      };
    };
    # services.nginx = {
    #   enable = true;
    # };
    networking.firewall.allowedTCPPorts = [8069];

    services.postgresql = {
      enable = true;
      package = pkgs.postgresql_15;
      dataDir = "${config.chr.system.persist.stateDir}/pgDB/${config.services.postgresql.package.psqlSchema}";

      ensureDatabases = ["odoo"];
      ensureUsers = [
        {
          name = "odoo";
          ensurePermissions = {"DATABASE odoo" = "ALL PRIVILEGES";};
        }
      ];
    };
  };
}
