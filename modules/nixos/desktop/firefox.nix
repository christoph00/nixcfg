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
      nativeMessagingHosts.packages = [ pkgs.firefoxpwa ];
      # package = pkgs.firefox-beta-bin;
      #package = perSystem.chaotic.firefox_nightly;
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

            # Unlike the user-specific browser configuration, we're just
            # considering the bare minimum set of preferred extensions.
            extensions = {
              "@contain-google".install_url = mozillaAddon "google-container";
              "@testpilot-containers".install_url = mozillaAddon "multi-account-containers";

              "passbolt@passbolt.com" = {
                install_url = mozillaAddon "passbolt";
                installation_mode = "force_installed";
                default_area = "navbar";
              };

              "uBlock0@raymondhill.net".install_url = mozillaAddon "ublock-origin";

              "de-DE@dictionaries.addons.mozilla.org".install_url = mozillaAddon "dictionary-german";

              "{3c078156-979c-498b-8990-85f7987dd929}".install_url = mozillaAddon "sidebery";

              "{b86e4813-687a-43e6-ab65-0bde4ab75758}".install_url =
                mozillaAddon "localcdn-fork-of-decentraleyes";

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
        # Don't tease me with the updates, man.
        "apps.update.auto" = false;

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

        "dom.security.https_first_pbm" = true;

        "privacy.firstparty.isolate" = true;

        "uc.tweak.floating-tabs" = true;
        "uc.tweak.rounded-corners" = true;
        "uc.tweak.hide-tabs-bar" = true;
        "uc.tweak.theme.sidebery" = true;
        "uc.tweak.disable-drag-space" = true;
        "uc.tweak.newtab-background" = false;
        "uc.tweak.hide-forward-button" = true;
        "uc.tweak.hide-newtab-logo" = true;
        "uc.tweak.force-tab-colour" = false;
        "uc.tweak.vertical-context-navigation" = false;
        "uc.tweak.context-menu.hide-access-key" = true;
        "uc.tweak.remove-tab-separators" = true;
        "uc.tweak.show-tab-close-button-on-hover" = true;
        "uc.tweak.smaller-context-menu-text" = true;
        "uc.tweak.revert-context-menu" = false;
        "uc.tweak.context-menu.hide-firefox-account" = true;
        "uc.tweak.context-menu.compact-extensions-menu" = true;

        "af.edgyarc.thin-navbar" = false;
        "af.edgyarc.minimal-navbar" = true;
        "uc.tweak.af.greyscale-webext-icons" = true;
        "af.edgyarc.centered-url" = true;
        "af.sidebery.edgyarc-theme" = true;
        "af.sidebery.minimal-collapsed" = true;
        "af.edgyarc.edge-sidebar" = false;
        "af.edgyarc.show-sidebar-header" = false;
        "af.edgyarc.autohide-sidebar" = false;
        "af.edgyarc.sidebar-always-collapsed" = false;
        "uc.tweak.af.sidebar-width-350" = false;
        "af.sidebery.nav-on-top" = false;
        "af.sidebery.static-pinned-tab-width" = false;

        # ****************************************************************************
        # * SECTION: FASTFOX                                                         *
        # ****************************************************************************

        # GENERAL
        "content.notify.interval" = 100000;

        # GFX
        "gfx.canvas.accelerated.cache-items" = 4096;
        "gfx.canvas.accelerated.cache-size" = 512;
        "gfx.content.skia-font-cache-size" = 20;

        # DISK CACHE
        "browser.cache.jsbc_compression_level" = 3;

        # MEDIA CACHE
        "media.memory_cache_max_size" = 65536;
        "media.cache_readahead_limit" = 7200;
        "media.cache_resume_threshold" = 3600;

        # IMAGE CACHE
        "image.mem.decode_bytes_at_a_time" = 32768;

        # NETWORK
        "network.buffer.cache.size" = 262144;
        "network.buffer.cache.count" = 128;
        "network.http.max-connections" = 1800;
        "network.http.max-persistent-connections-per-server" = 10;
        "network.http.max-urgent-start-excessive-connections-per-host" = 5;
        "network.http.pacing.requests.enabled" = false;
        "network.dnsCacheExpiration" = 3600;
        "network.dns.max_high_priority_threads" = 8;
        "network.ssl_tokens_cache_capacity" = 10240;

        # SPECULATIVE LOADING
        "network.dns.disablePrefetch" = false;
        "network.prefetch-next" = true;
        "network.predictor.enabled" = true;

        # EXPERIMENTAL
        "layout.css.grid-template-masonry-value.enabled" = true;
        "dom.enable_web_task_scheduling" = true;
        "layout.css.has-selector.enabled" = true;
        "dom.security.sanitizer.enabled" = true;

        # ****************************************************************************
        # * SECTION: SECUREFOX                                                       *
        # ****************************************************************************

        # TRACKING PROTECTION
        "browser.contentblocking.category" = "custom";
        "urlclassifier.trackingSkipURLs" = "*.reddit.com, *.twitter.com, *.twimg.com, *.tiktok.com";
        "urlclassifier.features.socialtracking.skipURLs" = "*.instagram.com, *.twitter.com, *.twimg.com";
        "network.cookie.sameSite.noneRequiresSecure" = true;
        "browser.download.start_downloads_in_tmp_dir" = true;
        "browser.helperApps.deleteTempFileOnExit" = true;
        "browser.uitour.enabled" = false;
        "privacy.globalprivacycontrol.enabled" = true;
        "privacy.globalprivacycontrol.functionality.enabled" = true;

        # OCSP & CERTS / HPKP
        "security.OCSP.enabled" = 0;
        "security.remote_settings.crlite_filters.enabled" = true;
        "security.pki.crlite_mode" = 2;

        # SSL / TLS
        "security.ssl.treat_unsafe_negotiation_as_broken" = true;
        "browser.xul.error_pages.expert_bad_cert" = true;
        "security.tls.enable_0rtt_data" = false;

        # DISK AVOIDANCE
        "browser.privatebrowsing.forceMediaMemoryCache" = true;
        "browser.sessionstore.interval" = 60000;

        # SHUTDOWN & SANITIZING
        "privacy.history.custom" = true;

        # SEARCH / URL BAR
        "browser.search.separatePrivateDefault.ui.enabled" = true;
        "browser.urlbar.update2.engineAliasRefresh" = true;
        # "browser.search.suggest.enabled" = false;
        "browser.urlbar.suggest.quicksuggest.sponsored" = false;
        "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
        "browser.formfill.enable" = false;
        "security.insecure_connection_text.enabled" = true;
        "security.insecure_connection_text.pbmode.enabled" = true;
        "network.IDN_show_punycode" = true;

        # HTTPS-FIRST POLICY
        "dom.security.https_first" = true;

        # PASSWORDS
        "signon.rememberSignons" = false;
        "signon.formlessCapture.enabled" = false;
        "signon.privateBrowsingCapture.enabled" = false;
        "network.auth.subresource-http-auth-allow" = 1;
        "editor.truncate_user_pastes" = false;

        # ADDRESS + CREDIT CARD MANAGER
        "extensions.formautofill.addresses.enabled" = false;
        "extensions.formautofill.creditCards.enabled" = false;

        # MIXED CONTENT + CROSS-SITE
        "security.mixed_content.block_display_content" = true;
        "security.mixed_content.upgrade_display_content" = true;
        "security.mixed_content.upgrade_display_content.image" = true;
        "pdfjs.enableScripting" = false;
        "extensions.postDownloadThirdPartyPrompt" = false;

        # HEADERS / REFERERS
        "network.http.referer.XOriginTrimmingPolicy" = 2;

        # CONTAINERS
        "privacy.userContext.ui.enabled" = true;

        # WEBRTC
        "media.peerconnection.ice.proxy_only_if_behind_proxy" = true;
        "media.peerconnection.ice.default_address_only" = true;

        # SAFE BROWSING
        "browser.safebrowsing.downloads.remote.enabled" = false;

        # MOZILLA
        "permissions.default.desktop-notification" = 0;
        "permissions.default.geo" = 0;
        "geo.provider.network.url" =
          "https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%";
        "permissions.manager.defaultsUrl" = "";
        "webchannel.allowObject.urlWhitelist" = "";

        # TELEMETRY
        "datareporting.policy.dataSubmissionEnabled" = false;
        "datareporting.healthreport.uploadEnabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.server" = "data:,";
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.newProfilePing.enabled" = false;
        "toolkit.telemetry.shutdownPingSender.enabled" = false;
        "toolkit.telemetry.updatePing.enabled" = false;
        "toolkit.telemetry.bhrPing.enabled" = false;
        "toolkit.telemetry.firstShutdownPing.enabled" = false;
        "toolkit.telemetry.coverage.opt-out" = true;
        "toolkit.coverage.opt-out" = true;
        "toolkit.coverage.endpoint.base" = "";
        "browser.ping-centre.telemetry" = false;
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;

        # EXPERIMENTS
        "app.shield.optoutstudies.enabled" = false;
        "app.normandy.enabled" = false;
        "app.normandy.api_url" = "";

        # CRASH REPORTS
        "breakpad.reportURL" = "";
        "browser.tabs.crashReporting.sendReport" = false;
        "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;

        # DETECTION
        "captivedetect.canonicalURL" = "";
        "network.captive-portal-service.enabled" = false;
        "network.connectivity-service.enabled" = false;

        # ****************************************************************************
        # * SECTION: PESKYFOX                                                        *
        # ****************************************************************************

        # MOZILLA UI
        "browser.privatebrowsing.vpnpromourl" = "";
        "extensions.getAddons.showPane" = false;
        "extensions.htmlaboutaddons.recommendations.enabled" = false;
        "browser.discovery.enabled" = false;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
        "browser.preferences.moreFromMozilla" = false;
        # "browser.tabs.tabmanager.enabled" = false;
        "browser.aboutConfig.showWarning" = false;
        "browser.aboutwelcome.enabled" = false;

        # THEME ADJUSTMENTS
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "browser.compactmode.show" = true;
        "browser.display.focus_ring_on_anything" = true;
        "browser.display.focus_ring_style" = 0;
        "browser.display.focus_ring_width" = 0;
        "layout.css.prefers-color-scheme.content-override" = 2;
        "browser.privateWindowSeparation.enabled" = false; # WINDOWS
        "svg.context-properties.content.enabled" = true;

        # COOKIE BANNER HANDLING
        "cookiebanners.service.mode" = 1;
        "cookiebanners.service.mode.privateBrowsing" = 1;
        "cookiebanners.service.enableGlobalRules" = true;

        # FULLSCREEN NOTICE
        "full-screen-api.transition-duration.enter" = "0 0";
        "full-screen-api.transition-duration.leave" = "0 0";
        "full-screen-api.warning.delay" = -1;
        "full-screen-api.warning.timeout" = 0;

        # URL BAR
        "browser.urlbar.suggest.calculator" = true;
        "browser.urlbar.unitConversion.enabled" = true;
        "browser.urlbar.trending.featureGate" = false;

        # NEW TAB PAGE
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;

        # POCKET
        "extensions.pocket.enabled" = false;

        # DOWNLOADS
        # "browser.download.useDownloadDir" = false;
        # "browser.download.always_ask_before_handling_new_types" = true;
        "browser.download.manager.addToRecentDocs" = false;

        # PDF
        "browser.download.open_pdf_attachments_inline" = true;

        # TAB BEHAVIOR
        "browser.bookmarks.openInTabClosesMenu" = false;
        "browser.menu.showViewImageInfo" = true;
        "findbar.highlightAll" = true;
        "layout.word_select.eat_space_to_next_word" = false;

        # ****************************************************************************
        # * START: MY OVERRIDES                                                      *
        # ****************************************************************************

        "media.hardwaremediakeys.enabled" = false;

        "widget.use-xdg-desktop-portal.file-picker" = 1;

      };

    };
  };
}
