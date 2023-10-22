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
    networking.firewall.allowedTCPPorts = [8069];

    virtualisation.oci-containers.containers = {
      "odoo-db" = {
        autoStart = true;
        image = "postgres:alpine";
        volumes = [
          "/media/ssd-data/container/odoo-db:/var/lib/postgresql/data"
        ];
        environment = {
          POSTGRES_PASSWORD = "odoo12";
          POSTGRES_DB = "odoo";
          POSTGRES_USER = "odoo";
        };
      };
      "odoo" = {
        autoStart = true;
        image = "odoo:latest";

        ports = [
          "8069:8069"
        ];
        volumes = [
          "/media/ssd-data/container/odoo-db:/var/lib/odoo"
        ];
        environment = {
          POSTGRES_HOST = "odoo-db";
          POSTGRES_PASSWORD = "odoo12"; # I am a bad thing
          POSTGRES_DB = "odoo";
          POSTGRES_USER = "odoo";
        };
        dependsOn = ["odoo-db"];
      };
    };
  };
}
