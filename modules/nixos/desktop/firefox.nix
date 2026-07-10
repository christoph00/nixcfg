{
  lib,
  flake,
  pkgs,
  config,
  perSystem,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (flake.lib) enabled;
  cfg = config.desktop;
in
{
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
      preferencesStatus = "default";

      policies = {
        AppAutoUpdate = false;

        Containers.Default =
          let
            mkContainer = name: color: icon: { inherit name color icon; };
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
            extensions = {
              "@contain-google".install_url = mozillaAddon "google-container";
              "@testpilot-containers".install_url = mozillaAddon "multi-account-containers";
              "uBlock0@raymondhill.net".install_url = mozillaAddon "ublock-origin";
              "de-DE@dictionaries.addons.mozilla.org".install_url = mozillaAddon "dictionary-german";
            };
            applyInstallationMode = name: value:
              lib.nameValuePair name (
                value // (lib.optionalAttrs (!(lib.hasAttrByPath [ "installation_mode" ] value)) {
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
        SanitizeOnShutdown = { FormData = true; };

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
          Remove = [ "Bing" "Amazon" "Wikipedia (en)" ];
        };

        UseSystemPrintDialog = true;
        UserMessaging = {
          ExtensionRecommendations = false;
          SkipOnboarding = true;
        };
      };

      preferences = {
        # Updates
        "apps.update.auto" = false;

        # Search & URL bar
        "browser.search.widget.inNavBar" = true;
        "browser.search.openintab" = true;
        "browser.urlbar.suggest.calculator" = true;
        "browser.urlbar.unitConversion.enabled" = true;
        "browser.urlbar.trending.featureGate" = false;
        "browser.urlbar.suggest.quicksuggest.sponsored" = false;
        "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
        "browser.formfill.enable" = false;

        # Privacy / Tracking
        "privacy.donottrackheader.enabled" = true;
        "privacy.trackingprotection.enabled" = true;
        "privacy.resistFingerprinting" = true;
        "privacy.fingerprintingProtection" = true;
        "privacy.fingerprintingProtection.pbmode" = true;
        "privacy.query_stripping.enabled" = true;
        "privacy.query_stripping.enabled.pbmode" = true;
        "privacy.firstparty.isolate" = true;
        "privacy.userContext.ui.enabled" = true;
        "privacy.history.custom" = true;
        "privacy.globalprivacycontrol.enabled" = true;
        "privacy.globalprivacycontrol.functionality.enabled" = true;

        "browser.contentblocking.category" = "custom";
        "browser.privatebrowsing.forceMediaMemoryCache" = true;
        "browser.download.start_downloads_in_tmp_dir" = true;
        "browser.helperApps.deleteTempFileOnExit" = true;

        # Network / DNS
        "network.dnsCacheExpiration" = 3600;
        "network.http.max-connections" = 1800;
        "network.http.max-persistent-connections-per-server" = 10;
        "network.http.pacing.requests.enabled" = false;
        "network.ssl_tokens_cache_capacity" = 10240;
        "network.cookie.sameSite.noneRequiresSecure" = true;
        "network.http.referer.XOriginTrimmingPolicy" = 2;
        "network.auth.subresource-http-auth-allow" = 1;

        # Security / TLS
        "dom.security.https_first" = true;
        "dom.security.https_first_pbm" = true;
        "security.ssl.treat_unsafe_negotiation_as_broken" = true;
        "browser.xul.error_pages.expert_bad_cert" = true;
        "security.tls.enable_0rtt_data" = false;
        "security.mixed_content.block_display_content" = true;
        "security.mixed_content.upgrade_display_content" = true;
        "security.mixed_content.upgrade_display_content.image" = true;
        "security.insecure_connection_text.enabled" = true;
        "security.insecure_connection_text.pbmode.enabled" = true;
        "network.IDN_show_punycode" = true;

        # OCSP / Certificates
        "security.OCSP.enabled" = 0;
        "security.remote_settings.crlite_filters.enabled" = true;
        "security.pki.crlite_mode" = 2;

        # Passwords
        "signon.rememberSignons" = false;
        "signon.formlessCapture.enabled" = false;
        "signon.privateBrowsingCapture.enabled" = false;

        # Forms / Autofill
        "extensions.formautofill.addresses.enabled" = false;
        "extensions.formautofill.creditCards.enabled" = false;

        # WebRTC
        "media.peerconnection.ice.proxy_only_if_behind_proxy" = true;
        "media.peerconnection.ice.default_address_only" = true;

        # PDF
        "pdfjs.enableScripting" = false;

        # Geolocation
        "permissions.default.desktop-notification" = 0;
        "permissions.default.geo" = 0;
        "geo.provider.network.url" =
          "https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%";
        "permissions.manager.defaultsUrl" = "";
        "webchannel.allowObject.urlWhitelist" = "";

        # Telemetry / Mozilla
        "datareporting.policy.dataSubmissionEnabled" = false;
        "datareporting.healthreport.uploadEnabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.server" = "data:,";
        "toolkit.telemetry.archive.enabled" = false;
        "browser.ping-centre.telemetry" = false;
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        "breakpad.reportURL" = "";
        "browser.tabs.crashReporting.sendReport" = false;
        "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
        "captivedetect.canonicalURL" = "";
        "network.captive-portal-service.enabled" = false;
        "network.connectivity-service.enabled" = false;

        # UI tweaks
        "browser.compactmode.show" = true;
        "browser.display.focus_ring_on_anything" = true;
        "browser.display.focus_ring_style" = 0;
        "browser.display.focus_ring_width" = 0;
        "layout.css.prefers-color-scheme.content-override" = 2;
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.bookmarks.openInTabClosesMenu" = false;
        "browser.menu.showViewImageInfo" = true;
        "full-screen-api.transition-duration.enter" = "0 0";
        "full-screen-api.transition-duration.leave" = "0 0";
        "full-screen-api.warning.delay" = -1;
        "full-screen-api.warning.timeout" = 0;
        "findbar.highlightAll" = true;
        "layout.word_select.eat_space_to_next_word" = false;
        "browser.download.open_pdf_attachments_inline" = true;
        "extensions.postDownloadThirdPartyPrompt" = false;
        "extensions.pocket.enabled" = false;

        # Cookie banners
        "cookiebanners.service.mode" = 1;
        "cookiebanners.service.mode.privateBrowsing" = 1;
        "cookiebanners.service.enableGlobalRules" = true;

        # Session restore
        "browser.sessionstore.interval" = 60000;
        "browser.aboutConfig.showWarning" = false;

        # Overrides
        "media.hardwaremediakeys.enabled" = false;
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        "editor.truncate_user_pastes" = false;

        # Hardware video acceleration (VAAPI)
        "gfx.x11-egl.force-enabled" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        "media.hardware-video-decoding.force-enabled" = true;
        "media.rdd-ffmpeg.enabled" = true;
      };
    };

    environment.etc."libva.conf" = mkIf config.hardware.graphics.enable {
      text = ''
        LIBVA_MESSAGING_LEVEL=1
      '';
    };

    environment.sessionVariables = mkIf config.hardware.graphics.enable {
      MOZ_DISABLE_RDD_SANDBOX = 1;
    };
  };
}
