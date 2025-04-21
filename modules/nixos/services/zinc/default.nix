{
  config,
  pkgs,
  lib,
  ...
}:
with builtins;
with lib;
with lib.internal;

let

  cfg = config.internal.services.zinc;
in
{
  imports = [ ];

  options.internal.services.zinc = {
    enable = mkBoolOpt false "Enable Zinc Search Service.";

    user = mkOption {
      type = lib.types.str;
      default = "zinc";
      description = "user account under which zinc runs";
    };
    group = mkOption {
      type = lib.types.str;
      default = "zinc";
      description = "group under which zinc runs";
    };
    dataDir = mkOption {
      type = lib.types.path;
      default = "/var/lib/zinc";
      description = ''the data directory for zinc'';
    };
    secretFile = mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''secret env variables for zinc'';
    };
    package = mkOption {
      default = pkgs.zinc;
      defaultText = literalExpression "pkgs.zinc";
      type = lib.types.package;
      description = ''zinc package to use'';
    };
    address = mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = ''zinc server IP address to bind to'';
    };
    port = mkOption {
      type = lib.types.port;
      default = 4080;
      description = ''zinc server listen http port'';
    };
    prometheus = mkOption {
      type = lib.types.bool;
      default = false;
      description = ''Enables prometheus metrics on /metrics endpoint'';
    };
    telemetry = mkOption {
      type = lib.types.bool;
      default = false;
      description = ''send anonymous telemetry info for improving zinc'';
    };
    sentry = mkOption {
      type = lib.types.bool;
      default = false;
      description = ''send anonymous sentry info for improving zinc'';
    };
    sentryDSN = mkOption {
      type = lib.types.str;
      default = "ingest.sentry.io";
      description = ''sentry DSN variable'';
    };
  };

  config = mkIf cfg.enable {
    users.users.${cfg.user} = {
      inherit (cfg) group;
      home = cfg.dataDir;
      createHome = true;
      isSystemUser = true;
    };
    users.groups.${cfg.group} = { };

    systemd.services.zinc = {
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      # env vars https://docs.zinc.dev/ZincSearch/environment-variables/
      environment = {
        HOME = cfg.dataDir;
        USER = cfg.user;
        GIN_MODE = "release";
        ZINC_PROMETHEUS_ENABLE = toString cfg.prometheus;
        ZINC_SENTRY = toString cfg.sentry;
        ZINC_SENTRY_DSN = cfg.sentryDSN;
        ZINC_SERVER_ADDRESS = cfg.address;
        ZINC_SERVER_PORT = toString cfg.port;
        ZINC_TELEMETRY = toString cfg.telemetry;
      };

      serviceConfig = {
        ${if cfg.secretFile != null then "EnvironmentFile" else null} = cfg.secretFile;
        ExecStart = ''
          ${cfg.package}/bin/zincsearch
        '';
        Restart = "on-failure";
        StateDirectory = "zinc";
        User = cfg.user;
        WorkingDirectory = cfg.dataDir;
      };
    };
  };
}
