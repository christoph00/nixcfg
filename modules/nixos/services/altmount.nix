{
  config,
  pkgs,
  lib,
  flake,
  perSystem,
  ...
}:

let
  cfg = config.services.altmount;
  inherit (flake.lib) mkBoolOpt mkIntOpt mkSecret;

  settingsFormat = pkgs.formats.yaml { };
in

{

  options.services.altmount = {
    enable = lib.mkEnableOption "AltMount";

    package = lib.mkPackageOption pkgs "altmount" { };

    user = lib.mkOption {
      type = lib.types.str;
      description = "The user account under which AltMount runs.";
      default = "altmount";
    };

    group = lib.mkOption {
      type = lib.types.str;
      description = "The group under which AltMount runs.";
      default = "altmount";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/altmount";
      description = "Base directory for AltMount data files.";
      readOnly = true;
    };


    settings = lib.mkOption {
      description = ''
        Configuration of Altmount. See <https://github.com/javi11/altmount/blob/main/config.sample.yaml> for more information.
      '';
      default = { };

      type = lib.types.submodule {
        freeformType = settingsFormat.type;

        options = {
          webdav = lib.mkOption {
            type = lib.types.submodule {
              options = {
                port = lib.mkOption {
                  type = lib.types.port;
                  default = 8080;
                  description = "WebDAV server port.";
                };

                user = lib.mkOption {
                  type = lib.types.str;
                  default = "usenet";
                  description = "WebDAV username.";
                };

                password = lib.mkOption {
                  type = lib.types.str;
                  default = "usenet";
                  description = "WebDAV password.";
                };
              };
            };
            default = {};
            description = "WebDAV server configuration.";
          };

          api = lib.mkOption {
            type = lib.types.submodule {
              options = {
                prefix = lib.mkOption {
                  type = lib.types.str;
                  default = "/api";
                  description = "API endpoint prefix.";
                };
              };
            };
            default = {};
            description = "REST API configuration.";
          };

          auth = lib.mkOption {
            type = lib.types.submodule {
              options = {
                login_required = lib.mkOption {
                  type = lib.types.bool;
                  default = true;
                  description = "Require login to access WebDAV and API.";
                };
              };
            };
            default = {};
            description = "Authentication configuration.";
          };

          database = lib.mkOption {
            type = lib.types.submodule {
              options = {
                path = lib.mkOption {
                  type = lib.types.str;
                  default = "${cfg.dataDir}/altmount.db";
                  description = "Database path for processing workflows.";
                };
              };
            };
            default = {};
            description = "Database configuration.";
          };

          metadata = lib.mkOption {
            type = lib.types.submodule {
              options = {
                root_path = lib.mkOption {
                  type = lib.types.str;
                  default = "${cfg.dataDir}/metadata";
                  description = "Directory to store metadata files.";
                };

                delete_source_nzb_on_removal = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                  description = "Delete source NZB file when metadata is removed.";
                };
              };
            };
            default = {};
            description = "Metadata filesystem configuration.";
          };

          streaming = lib.mkOption {
            type = lib.types.submodule {
              options = {
                max_download_workers = lib.mkOption {
                  type = lib.types.int;
                  default = 15;
                  description = "Number of download workers.";
                };

                max_cache_size_mb = lib.mkOption {
                  type = lib.types.int;
                  default = 32;
                  description = "Maximum cache size in MB for ahead download chunks.";
                };
              };
            };
            default = {};
            description = "Streaming and download configuration.";
          };

          import = lib.mkOption {
            type = lib.types.submodule {
              options = {
                max_processor_workers = lib.mkOption {
                  type = lib.types.int;
                  default = 2;
                  description = "Number of NZB processor workers.";
                };

                queue_processing_interval_seconds = lib.mkOption {
                  type = lib.types.int;
                  default = 5;
                  description = "Queue processing interval in seconds.";
                };

                allowed_file_extensions = lib.mkOption {
                  type = lib.types.listOf lib.types.str;
                  default = [
                    ".mp4" ".mkv" ".avi" ".mov" ".wmv" ".flv" ".webm" ".m4v"
                    ".mpg" ".mpeg" ".m2ts" ".ts" ".vob" ".3gp" ".3g2"
                    ".h264" ".h265" ".hevc" ".ogv" ".ogm" ".strm" ".iso"
                    ".img" ".divx" ".xvid" ".rm" ".rmvb" ".asf" ".asx"
                    ".wtv" ".mk3d" ".dvr-ms"
                  ];
                  description = "Allowed file extensions for import.";
                };

                max_import_connections = lib.mkOption {
                  type = lib.types.int;
                  default = 5;
                  description = "Number of concurrent NNTP connections for validation and archive processing.";
                };

                import_cache_size_mb = lib.mkOption {
                  type = lib.types.int;
                  default = 64;
                  description = "Cache size in MB for archive analysis.";
                };

                segment_sample_percentage = lib.mkOption {
                  type = lib.types.int;
                  default = 1;
                  description = "Percentage of segments to sample for validation (1-100).";
                };

                import_strategy = lib.mkOption {
                  type = lib.types.str;
                  default = "NONE";
                  description = "Import strategy: NONE, SYMLINK, or STRM.";
                };

                import_dir = lib.mkOption {
                  type = lib.types.str;
                  default = "";
                  description = "Import directory (required when import_strategy is SYMLINK or STRM).";
                };
              };
            };
            default = {};
            description = "Import processing configuration.";
          };

          health = lib.mkOption {
            type = lib.types.submodule {
              options = {
                enabled = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                  description = "Enable health monitoring service.";
                };

                library_dir = lib.mkOption {
                  type = lib.types.str;
                  default = "";
                  description = "Library directory to monitor (required when health is enabled).";
                };

                cleanup_orphaned_files = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                  description = "Clean up orphaned files, metadata, and empty directories.";
                };

                check_interval_seconds = lib.mkOption {
                  type = lib.types.int;
                  default = 5;
                  description = "Health check interval in seconds.";
                };

                max_connections_for_health_checks = lib.mkOption {
                  type = lib.types.int;
                  default = 5;
                  description = "Number of NNTP connections for health checks.";
                };

                segment_sample_percentage = lib.mkOption {
                  type = lib.types.int;
                  default = 5;
                  description = "Percentage of segments to sample for health validation (1-100).";
                };

                library_sync_interval_minutes = lib.mkOption {
                  type = lib.types.int;
                  default = 360;
                  description = "Library synchronization interval in minutes.";
                };

                library_sync_concurrency = lib.mkOption {
                  type = lib.types.int;
                  default = 1;
                  description = "Number of concurrent library sync operations.";
                };
              };
            };
            default = {};
            description = "Health monitoring configuration.";
          };

          mount_path = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "WebDAV mount path (e.g., '/mnt/altmount' or '/mnt/unionfs').";
          };

          sabnzbd = lib.mkOption {
            type = lib.types.submodule {
              options = {
                enabled = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                  description = "Enable SABnzbd-compatible API.";
                };

                complete_dir = lib.mkOption {
                  type = lib.types.str;
                  default = "${cfg.dataDir}/complete";
                  description = "The complete directory where the files will be 'downloaded'.";
                };

                categories = lib.mkOption {
                  type = lib.types.listOf (lib.types.submodule {
                    options = {
                      name = lib.mkOption {
                        type = lib.types.str;
                        description = "Category name.";
                      };
                      order = lib.mkOption {
                        type = lib.types.int;
                        description = "Category order.";
                      };
                      priority = lib.mkOption {
                        type = lib.types.int;
                        description = "Category priority.";
                      };
                      dir = lib.mkOption {
                        type = lib.types.str;
                        description = "Category directory.";
                      };
                    };
                  });
                  default = [];
                  description = "Download categories.";
                };

                fallback_host = lib.mkOption {
                  type = lib.types.str;
                  default = "";
                  description = "External SABnzbd URL for fallback.";
                };

                fallback_api_key = lib.mkOption {
                  type = lib.types.str;
                  default = "";
                  description = "External SABnzbd API key for fallback.";
                };
              };
            };
            default = {};
            description = "SABnzbd-compatible API configuration.";
          };

          arrs = lib.mkOption {
            type = lib.types.submodule {
              options = {
                enabled = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                  description = "Enable arrs service.";
                };

                max_workers = lib.mkOption {
                  type = lib.types.int;
                  default = 5;
                  description = "Number of concurrent workers.";
                };

                radarr_instances = lib.mkOption {
                  type = lib.types.listOf lib.types.attrs;
                  default = [];
                  description = "Radarr instances (configured via UI).";
                };

                sonarr_instances = lib.mkOption {
                  type = lib.types.listOf lib.types.attrs;
                  default = [];
                  description = "Sonarr instances (configured via UI).";
                };
              };
            };
            default = {};
            description = "Radarr/Sonarr arrs configuration.";
          };

          log = lib.mkOption {
            type = lib.types.submodule {
              options = {
                file = lib.mkOption {
                  type = lib.types.str;
                  default = "${cfg.dataDir}/altmount.log";
                  description = "Log file path (empty = console only).";
                };

                level = lib.mkOption {
                  type = lib.types.str;
                  default = "info";
                  description = "Log level: debug, info, warn, error.";
                };

                max_size = lib.mkOption {
                  type = lib.types.int;
                  default = 100;
                  description = "Maximum size in MB before rotation.";
                };

                max_age = lib.mkOption {
                  type = lib.types.int;
                  default = 30;
                  description = "Maximum age in days to keep old files.";
                };

                max_backups = lib.mkOption {
                  type = lib.types.int;
                  default = 10;
                  description = "Maximum number of old files to keep.";
                };

                compress = lib.mkOption {
                  type = lib.types.bool;
                  default = true;
                  description = "Compress old log files.";
                };
              };
            };
            default = {};
            description = "Logging configuration with rotation support.";
          };

          log_level = lib.mkOption {
            type = lib.types.str;
            default = "info";
            description = "Global log level (legacy - use log.level instead).";
          };

          profiler_enabled = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable performance profiling.";
          };

          providers = lib.mkOption {
            type = lib.types.listOf (lib.types.submodule {
              options = {

                host = lib.mkOption {
                  type = lib.types.str;
                  description = "Provider hostname.";
                };

                port = lib.mkOption {
                  type = lib.types.port;
                  description = "Provider port.";
                };

                username = lib.mkOption {
                  type = lib.types.str;
                  description = "Provider username.";
                };

                password = lib.mkOption {
                  type = lib.types.str;
                  description = "Provider password.";
                };

                max_connections = lib.mkOption {
                  type = lib.types.int;
                  description = "Maximum number of connections.";
                };

                tls = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                  description = "Use TLS/SSL.";
                };

                insecure_tls = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                  description = "Allow insecure TLS connections.";
                };

                enabled = lib.mkOption {
                  type = lib.types.bool;
                  default = true;
                  description = "Enable/disable this provider.";
                };

                is_backup_provider = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                  description = "Mark as backup provider.";
                };
              };
            });
            default = [];
            description = "NNTP providers configuration.";
            example = [
              {
                host = "ssl-news.provider.com";
                port = 563;
                username = "your_username";
                password = "your_password";
                max_connections = 20;
                tls = true;
              }
            ];
          };
        };
      };
    };

    extraConfigFiles = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ ];
      example = [ "/run/secrets/altmount.yaml" ];
      description = ''
        Config files to merge into the settings defined in [](#opt-services.altmount.settings).
        This is useful to avoid putting secrets into the nix store.
        See <https://github.com/javi11/altmount/blob/main/config.sample.yaml> for more information.
      '';
    };
  };

  config = lib.mkIf cfg.enable {

   age.secrets.altmount-cfg = mkSecret {
      file = "altmount-cfg";
      owner = "altmount";
    };


    services.altmount = {
      package = perSystem.self.altmount;
      extraConfigFiles = [ config.age.secrets.altmount-cfg.path ];
    };

    systemd.services.altmount = {
      description = "AltMount";

      wantedBy = [ "multi-user.target" ];

      wants = [
        "network-online.target"
        "local-fs.target"
      ];
      after = [
        "network-online.target"
        "local-fs.target"
      ];

      preStart = ''
        shopt -s nullglob

        tmp="$(mktemp)"
        ${lib.getExe pkgs.yq-go} eval-all '. as $item ireduce ({}; . *+ $item)' \
          ${settingsFormat.generate "altmount-config.yaml" cfg.settings} \
          $CREDENTIALS_DIRECTORY/config-*.yaml > "$tmp"
        chmod -w "$tmp"

        mkdir -p /run/altmount
        mv "$tmp" /run/altmount/config.yaml

        # Create subdirectories in state directory
        mkdir -p ${cfg.dataDir}/metadata ${cfg.dataDir}/cache ${cfg.dataDir}/complete
        chown -R ${cfg.user}:${cfg.group} ${cfg.dataDir}
      '';

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        RuntimeDirectory = "altmount";
        StateDirectory = "altmount";
        StateDirectoryMode = "0755";
        Restart = "always";

        LoadCredential = lib.imap0 (i: path: "config-${toString i}.yaml:${path}") cfg.extraConfigFiles;

        ExecStart = "${lib.getExe cfg.package} serve --config /run/altmount/config.yaml";
      };
    };

    users.users = lib.mkIf (cfg.user == "altmount") {
      altmount = {
        group = cfg.group;
        isSystemUser = true;
      };
    };

    users.groups = lib.mkIf (cfg.group == "altmount") { altmount = { }; };
  };
}