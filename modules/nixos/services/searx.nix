{
  lib,
  config,
  flake,
  ...
}:

let
  inherit (lib) mkIf;
  inherit (flake.lib) mkSecret mkBoolOpt mkStrOpt;
  cfg = config.svc.searx;
in
{

  options.svc.searx = {
    enable = mkBoolOpt false;

    domain = mkStrOpt "search.${config.networking.domain}";

  };

  config = mkIf cfg.enable {
    users.users.nginx.extraGroups = [ "searx" ];

    age.secrets."searx" = mkSecret { file = "searx"; };

    sys.state.directories = [ "/var/lib/searx" ];

    services = {
      nginx.enable = true;
      nginx.virtualHosts.${cfg.domain} = {
        listen = [
          {
            addr = "0.0.0.0";
            port = 1033;
            ssl = false;
          }
        ];
        locations = {
          "/" = {
            extraConfig = ''
              uwsgi_pass unix:${config.services.searx.uwsgiConfig.socket};
            '';
          };
          "/static/" = {
            alias = "${config.services.searx.package}/share/static/";
          };
        };
      };

      searx = {
        enable = true;
        runInUwsgi = true;
        redisCreateLocally = true;
        environmentFile = config.age.secrets.searx.path;
        uwsgiConfig = {
          disable-logging = true;
          socket = "/run/searx/searx.sock";
          chmod-socket = "660";
          http = "";
        };
        settings = {
          use_default_settings = true;
          general = {
            debug = false;
            instance_name = cfg.domain;
            privacypolicy_url = false;
          };
          ui = {
            static_use_hash = true;
            query_in_title = true;
            infinite_scroll = false;
            center_alignment = true;
            hotkeys = "vim";
            engine_shortcuts = true;
            expand_results = true;
          };
          server = {
            secret_key = "@SECRET_KEY@";
            base_url = "https://${cfg.domain}";
            default_locale = "de";
            default_theme = "oscar";
            public_instance = false;
            image_proxy = true;
            http_protocol_version = "1.1";
          };
          outgoing = {
            enable_http2 = true;
            max_request_timeout = 15.0;
            request_timeout = 5.0;
            pool_connections = 200;
            pool_maxsize = 30;
            dns_resolver = {
              enable = true;
              use_system_resolver = true;
              resolver_address = "127.0.0.1";
            };
          };
          engines =
            let
              pageSize = 100;
            in
            (lib.mapAttrsToList (name: value: { inherit name; } // value) {
              # General search
              "duckduckgo".disabled = false;
              "bing".disabled = false;
              "google".disabled = false;
              "brave".disabled = true;
              "crates.io".disabled = false;
              "npm".disabled = false;
              "pub.dev".disabled = false;
              "pkg.go.dev".disabled = false;
              "gitlab".disabled = false;
              "codeberg".disabled = false;
              "bitbucket".disabled = false;
              "sourcehut".disabled = false;
              "github".disabled = false;
              "lobste.rs".disabled = false;
              "hackernews".disabled = false;
              "annas archive".disabled = false;
              "lib.rs".disabled = false;
              "library genesis".disabled = false;
              "packagist".disabled = false;
              "wikinews".disabled = false;
              "tagesschau".disabled = false;
              "reddit".disabled = false;
              "duckduckgo images".disabled = false;

            })
            ++ [
              {
                name = "nixos wiki";
                shortcut = "nw";
                engine = "mediawiki";
                base_url = "https://wiki.nixos.org/";
                categories = "nix";
                timeout = 3;
                disabled = false;
              }
              {
                name = "nixos options";
                shortcut = "no";
                engine = "xpath";
                search_url = "https://search.nixos.org/options?channel=unstable&from={pageno}&size=${toString pageSize}&sort=relevance&type=packages&query={query}";
                results_xpath = "/html/body/shortcut-element/div/div/div/div/div/div/ul";
                content_xpath = "/div";
                title_xpath = "/span/a";
                suggestion_xpath = "/ul";
                url_xpath = "/span/a";
                paging = true;
                page_size = pageSize;
                categories = "nix";
                timeout = 3;
                disabled = false;
              }
              {
                name = "nixos packages";
                shortcut = "np";
                engine = "xpath";
                search_url = "https://search.nixos.org/packages?channel=unstable&from={pageno}&size=${toString pageSize}&sort=relevance&type=packages&query={query}";
                results_xpath = "/html/body/shortcut-element/div/div/div/div/div/div/ul";
                content_xpath = "/div";
                title_xpath = "/span/a";
                suggestion_xpath = "/ul";
                url_xpath = "/span/a";
                paging = true;
                page_size = pageSize;
                categories = "nix";
                timeout = 3;
                disabled = false;
              }
            ];
          enable_plugins = [
            "Basic Calculator"
            "Hash plugin"
            "Open Access DOI rewrite"
            "Hostnames plugin"
            "Unit converter plugin"
            "Tracker URL remover"
          ];
          hostnames = {
            replace = {
              "(.*\.)?reddit\.com$" = "old.reddit.com";
              "(.*\.)?redd\.it$" = "old.reddit.com";
            };
            remove = [
              "(.*\.)?redditmedia.com$"
              "(.*\.)?facebook.com$"
              "(.*\.)?softonic.com$"
              "(.*\.)?nixos.wiki$"
            ];
            high_priority = [
              "(.*\.)?wikipedia.com$"
              "(.*\.)?reddit.com$"
              "(.*\.)?github.com$"

              "(.*\.)?nixos.org$"
              "(.*\.)archlinux.org$"
            ];
            low_priority = [

            ];
          };
          search = {
            safe_search = 0;
            formats = [
              "html"
              "json"
              "rss"
            ];
            max_page = 10;
            default_lang = "all";
            autocomplete = "duckduckgo";
            favicon_resolver = "duckduckgo";

          };

          limiterSettings = {
            real_ip = {
              x_for = 1;
              ipv4_prefix = 32;
              ipv6_prefix = 56;
            };
            botdetection.ip_lists.block_ip = [
            ];
            botdetection.ip_lists.pass_ip = [
            ];
          };

          cache = {
            cache_max_age = 1440; # Cache for 24 hours
            cache_disabled_plugins = [ ];
            cache_dir = "/var/lib/searx";
          };

          faviconsSettings = {
            favicons = {
              cfg_schema = 1;
              cache = {
                db_url = "/var/lib/searx/faviconcache.db";
                HOLD_TIME = 5184000;
                LIMIT_TOTAL_BYTES = 2147483648;
                BLOB_MAX_BYTES = 40960;
                MAINTENANCE_MODE = "auto";
                MAINTENANCE_PERIOD = 600;
              };
            };
          };

        };
      };

    };

  };
}
