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
  cfg = config.internal.services.glance;

in
{

  options.internal.services.glance = {
    enable = mkBoolOpt false "Enable Glance Dashboard.";
    host = mkOption {
      type = types.str;
      default = "0.0.0.0";
    };
    port = mkOption {
      type = types.int;
      default = 5001;
    };

  };

  config = mkIf cfg.enable {

    services.caddy.virtualHosts."dash.r505.de" = {
      extraConfig = # caddyfile
        ''
          tls {
            dns cloudflare {env.CLOUDFLARE_API_TOKEN}
            resolvers 1.1.1.1
          }
          header -Alt-svc
          reverse_proxy http://127.0.0.1:${toString cfg.port}
        '';
    };

    services.glance = {
      enable = true;
      settings = {
        server = {
          inherit (cfg) port host;
        };
        theme = {
          light = true;
          background-color = "0 0 95";
          primary-color = "0 0 10";
          negative-color = "0 90 50";
        };
        pages = [
          {
            name = "Home";
            columns = [
              {
                size = "small";
                widgets = [
                  # {
                  #   type = "bookmarks";
                  #   groups = lib.lists.singleton {
                  #     links = [
                  #       {
                  #         title = "Cloud";
                  #         url = "https://cloud.r505.de";
                  #       }
                  #       {
                  #         title = "Home Assistant";
                  #         url = "https://ha.r505.de";
                  #       }
                  #     ];
                  #   };
                  # }
                  {
                    type = "clock";
                    hour-format = "24h";
                  }
                  { type = "calendar"; }
                  {
                    type = "weather";
                    location = "Hannover, Germany";
                  }
                  {
                    type = "markets";
                    markets = [
                      {
                        name = "DTAG";
                        symbol = "DTE.DE";

                      }
                      {
                        name = "A1JX52";
                        symbol = "VGWL.DE";
                      }
                    ];
                  }
                  {
                    type = "monitor";
                    cache = "1m";
                    title = "Services";
                    style = "compact";
                    sites = [
                      {
                        title = "Cloud";
                        url = "https://cloud.r505.de";

                      }
                      {
                        title = "Home Assistant";
                        url = "https://ha.r505.de";
                      }
                    ];
                  }
                  {
                    type = "server-stats";
                    servers = [
                      {
                        type = "local";
                        name = "oca";
                      }
                    ];
                  }
                ];
              }
              {
                size = "full";
                widgets = [
                  {
                    type = "search";
                    search-engine = "duckduckgo";
                    autofocus = true;
                    new-tab = true;
                    bangs = [
                      {
                        title = "Youtube";
                        shortcut = "yt";
                        url = "https://www.youtube.com/results?search_query={QUERY}";
                      }
                      {
                        title = "GitHub";
                        shortcut = "gh";
                        url = "https://github.com/search?q={QUERY}";
                      }
                      {
                        title = "Reddit";
                        shortcut = "r";
                        url = "https://www.reddit.com/search?q={QUERY}";
                      }
                      {
                        title = "Nix Packages";
                        shortcut = "nix";
                        url = "https://search.nixos.org/packages?query={QUERY}";
                      }
                    ];

                  }

                  { type = "hacker-news"; }
                  { type = "lobsters"; }

                ];
              }
            ];
          }
        ];
      };
    };
  };
}
