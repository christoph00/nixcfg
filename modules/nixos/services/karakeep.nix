{config, lib, ...}:
let
  inherit (lib) mkIf;
  inherit (flake.lib) mkBoolOpt mkIntOpt mkSecret;
  cfg = config.services.karakeep;
in {
  options.services.karakeep = {
    port = mkOption {
      type = lib.types.number;
      default = 3050;
    };
  };
  config = mkIf config.services.karakeep.enable {
  
   age.secrets.karakeep-cfg = mkSecret {
      file = "karakeep-cfg";
    };
    sys.state.directories = ["/var/lib/karakeep"];
    services.karakeep= {
      environmentFile = config.age.secrets.karakeep-cfg.path;
      meilisearch.enable = true;
          extraEnvironment = {
            DISABLE_SIGNUPS = "false";
            DISABLE_NEW_RELEASE_CHECK = "true";
            DB_WAL_MODE = "true";
            PORT = "${toString cfg.port}";
            CRAWLER_FULL_PAGE_SCREENSHOT = "true";
            CRAWLER_FULL_PAGE_ARCHIVE = "true";
            CRAWLER_VIDEO_DOWNLOAD = "true";
          };
      
    };

  };
}
