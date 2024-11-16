{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib,
  # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs,
  # You also have access to your flake's inputs.
  config,
  inputs,
  ...
}:

with builtins;
with lib;
with lib.internal;

let
  cfg = config.internal.graphical.apps.firefox;

in
{

  options.internal.graphical.apps.firefox = {
    enable = mkBoolOpt config.internal.isGraphical "Enable Firefox.";
  };

  config = mkIf cfg.enable {

    xdg.mime = {
      enable = true;
      defaultApplications = {
        "default-web-browser" = [ "firefox.desktop" ];
        "text/html" = [ "firefox.desktop" ];
        "x-scheme-handler/http" = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];
        "x-scheme-handler/about" = [ "firefox.desktop" ];
        "x-scheme-handler/unknown" = [ "firefox.desktop" ];
      };
    };

    programs.firefox = {
      enable = true;
      package = pkgs.firefox-beta-bin;

      policies = {
        AppAutoUpdate = false;

        Containers.Default =
          let
            mkContainer = name: color: icon: {
              inherit name color icon;
            };
          in
          [
            (mkContainer "Personal" "blue" "fingerprint")
            (mkContainer "Self-hosted" "pink" "fingerprint")
            (mkContainer "Shopping" "pink" "cart")
            (mkContainer "Gaming" "turquoise" "chill")
          ];

        DisableAppUpdate = true;
        DisableMasterPasswordCreation = true;
        DisablePocket = true;
        DisableSetDesktopBackground = true;
        DontCheckDefaultBrowser = true;

        ExtensionSettings =
          let
            mozillaAddon = id: "https://addons.mozilla.org/firefox/downloads/latest/${id}/latest.xpi";

            # Unlike the user-specific browser configuration, we're just
            # considering the bare minimum set of preferred extensions.
            extensions = {
              "@contain-google".install_url = mozillaAddon "google-container";
              "@testpilot-containers".install_url = mozillaAddon "multi-account-containers";

              # "ncpasswords@mdns.eu" = {
              # install_url = mozillaAddon "nextcloud-passwords";
              # installation_mode = "force_installed";
              # default_area = "navbar";
              # };

              "uBlock0@raymondhill.net".install_url = mozillaAddon "ublock-origin";

              "de-DE@dictionaries.addons.mozilla.org".install_url = mozillaAddon "dictionary-german";

            };

            applyInstallationMode =
              name: value:
              lib.nameValuePair name (
                value
                // (lib.optionalAttrs (!(lib.hasAttrByPath [ "installation_mode" ] value)) {
                  installation_mode = "normal_installed";
                })
              );
          in
          lib.mapAttrs' applyInstallationMode extensions;

        FirefoxHome = {
          Highlights = false;
          Pocket = false;
          Snippets = false;
          SponsporedPocket = false;
          SponsporedTopSites = false;
        };
        NoDefaultBookmarks = true;
        OfferToSaveLoginsDefault = false;
        PasswordManagerEnabled = false;
        SanitizeOnShutdown = {
          FormData = true;
        };

        SearchEngines = {
          Add = [
            {
              Name = "Brave";
              URLTemplate = "https://search.brave.com/search?q={searchTerms}";
              Method = "GET";
              IconURL = "https://brave.com/static-assets/images/brave-favicon.png";
              Alias = "brave";
              SuggestURLTemplate = "https://search.brave.com/api/suggest?q={searchTerms}";
            }

            {
              Name = "nixpkgs";
              URLTemplate = "https://search.nixos.org/packages?type=packages&query={searchTerms}";
              Method = "GET";
              Alias = "nixpkgs";
              IconURL = "file://${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            }

            {
              Name = "nix code";
              URLTemplate = "https://github.com/search?q={searchTerms}+lang%3Anix&type=code";
              Method = "GET";
              Alias = "nix";
              IconURL = "file://${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            }
          ];
          Default = "Brave";
          Remove = [
            "Bing"
            "Amazon"
            "Wikipedia (en)"
          ];
        };

        UseSystemPrintDialog = true;
        UserMessaging = {
          ExtensionRecommendations = false;
          SkipOnboarding = true;
        };
      };

      preferences = {
        # Disable the UI tour.
        "browser.uitour.enabled" = false;

        # Don't tease me with the updates, man.
        "apps.update.auto" = false;

        # Some inconveniences of life (at least for me).
        "extensions.pocket.enabled" = false;
        "signon.rememberSignons" = false;

        # Some quality of lifes.
        "browser.search.widget.inNavBar" = true;
        "browser.search.openintab" = true;

        # Some privacy settings...
        "privacy.donottrackheader.enabled" = true;
        "privacy.trackingprotection.enabled" = true;

        # Burn our own fingers.
        "privacy.resistFingerprinting" = true;
        "privacy.fingerprintingProtection" = true;
        "privacy.fingerprintingProtection.pbmode" = true;

        "privacy.query_stripping.enabled" = true;
        "privacy.query_stripping.enabled.pbmode" = true;

        "dom.security.https_first" = true;
        "dom.security.https_first_pbm" = true;

        "privacy.firstparty.isolate" = true;
      };
    };
  };

}
