{
  flake,
  config,
  lib,
  perSystem,
  ...
}: let
  inherit (lib) mkIf;
  inherit (flake.lib) mkBoolOpt mkIntOpt mkSecret;
  cfg = config.services.karakeep;
in {
  options.services.karakeep = {
    port = mkIntOpt 3050;
  };
  config = mkIf config.services.karakeep.enable {
    age.secrets.karakeep-cfg = mkSecret {
      file = "karakeep-cfg";
    };
    sys.state.directories = ["/var/lib/karakeep"];
    services.karakeep = {
      package = perSystem.nixpkgs-unstable.karakeep;
      environmentFile = config.age.secrets.karakeep-cfg.path;
      meilisearch.enable = true;
      extraEnvironment = {
        NEXTAUTH_URL = "https://keep.r505.de";
        DISABLE_SIGNUPS = "true";
        DISABLE_NEW_RELEASE_CHECK = "true";
        DB_WAL_MODE = "true";
        PORT = "${toString cfg.port}";
        CRAWLER_NUM_WORKERS = "2";
        CRAWLER_JOB_TIMEOUT_SEC = "120";
        CRAWLER_NAVIGATE_TIMEOUT_SEC = "60";
        CRAWLER_FULL_PAGE_SCREENSHOT = "true";
        CRAWLER_FULL_PAGE_ARCHIVE = "false";
        CRAWLER_VIDEO_DOWNLOAD = "false";
      };
    };
  };
}
