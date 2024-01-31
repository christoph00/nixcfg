rec {
  buildTargets = targets:
    builtins.concatStringsSep
    "\n"
    (map (target: "{\"__address__\" = \"${target}\"},") targets);

  buildStaticScrape = config @ {...}: let
    targets = buildTargets config.targets;
    forwardTo = builtins.concatStringsSep ",\n" config.forwardTo;

    bearerConfig =
      if config.bearerTokenFile != ""
      then rec {
        secretName = "${config.name}_bearer";
        localFile = ''
          local.file "${secretName}" {
            filename = "${config.bearerTokenFile}"
            is_secret = true
          }
        '';
        scrapeConfig = ''
          authorization {
            type = "Bearer"
            credentials = local.file.${secretName}.content
          }
        '';
      }
      else {
        secretName = "";
        localFile = "";
        scrapeConfig = "";
      };
  in ''
    ${bearerConfig.localFile}
    prometheus.scrape "${config.name}" {
      forward_to = [
        ${forwardTo},
      ]

      targets = [
        ${targets}
      ]

      ${bearerConfig.scrapeConfig}

      scrape_interval = "${config.scrapeInterval}"
      metrics_path = "${config.metricsPath}"
    }
  '';

  buildScrapeSet = scrapeSet: let
    built =
      builtins.mapAttrs
      (name: config:
        buildStaticScrape ({inherit name;} // config))
      scrapeSet;
  in
    builtins.concatStringsSep
    "\n"
    (map (name: built.${name}) (builtins.attrNames built));
}
