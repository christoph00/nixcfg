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
    services.glance = {
      enable = true;
      settings = {
        server = {
          inherit (cfg) port host;
        };
        theme = {
          background-color = "240 13 14";
          primary-color = "50 33 68";
          negative-color = "358 100 68";
          contrast-multiplier = 1.2;
        };
        pages = [
          {
            name = "Home";
            columns = [
              {
                size = "small";
                widgets = [
                  {
                    type = "bookmarks";
                    groups = lib.lists.singleton {
                      links = [
                        {
                          title = "GitHub";
                          url = "https://github.com";
                        }
                        {
                          title = "NixOS Status";
                          url = "https://status.nixos.org";
                        }
                      ];
                    };
                  }
                  {
                    type = "clock";
                    hour-format = "24h";
                    timezones = [ { timezone = "Europe/Berlin"; } ];
                  }
                  { type = "calendar"; }
                  {
                    type = "weather";
                    location = "Hannover, Germany";
                  }
                ];
              }
              {
                size = "full";
                widgets = [
                  { type = "hacker-news"; }
                  { type = "lobsters"; }
                  {
                    type = "reddit";
                    subreddit = "neovim";
                  }
                  {
                    type = "reddit";
                    subreddit = "unixporn";
                  }
                ];
              }
            ];
          }
        ];
      };
    };
  };
}
