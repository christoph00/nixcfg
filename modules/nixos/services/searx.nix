{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib,
  # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs,
  # You also have access to your flake's inputs.
  inputs,
  # Additional metadata is provided by Snowfall Lib.
  namespace,
  # The namespace used for your flake, defaulting to "internal" if not set.
  system,
  # The system architecture for this host (eg. `x86_64-linux`).
  target,
  # The Snowfall Lib target for this system (eg. `x86_64-iso`).
  format,
  # A normalized name for the system target (eg. `iso`).
  virtual,
  # A boolean to determine whether this system is a virtual target using nixos-generators.
  systems, # An attribute map of your defined hosts.

  # All other arguments come from the module system.
  config,
  ...
}:

with builtins;
with lib;
with lib.internal;

let
  cfg = config.internal.services.searx;
in
{

  options.internal.services.searx = {
    enable = mkBoolOpt false "Enable SearX Service.";
    domain = mkOption {
      type = types.str;
      default = "search.r505.de";
      description = "The domain to use for SearX.";
    };
  };

  config = mkIf cfg.enable {
    users.users.nginx.extraGroups = [ "searx" ];

    age.secrets."searx".file = ../../../../secrets/searx.env;

    services = {
      nginx.virtualHosts.${cfg.domain} = {
        useACMEHost = "r505.de";
        forceSSL = true;
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
          };
          ui = {
            static_use_hash = true;
            query_in_title = true;
            infinite_scroll = false;
            center_alignment = true;
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

              # For wiki articles
              "(.*\.)?nixos.org$"
              "(.*\.)archlinux.org$"
            ];
            low_priority = [

            ];
          };
          search = {
            formats = [
              "html"
              "json"
            ];
            max_page = 10;
            default_lang = "en";
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
              # "93.184.216.34" # example.org
            ];
            botdetection.ip_lists.pass_ip = [
              "130.162.232.230" # dade1
            ];
          };

          faviconsSettings = {
            favicons = {
              cfg_schema = 1;
              cache = {
                db_url = "/run/searx/faviconcache.db";
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
