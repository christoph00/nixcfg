{
  pkgs,
  lib,
  inputs,
  config,
  ...
}: let
  cfg = config.conf.applications.firefox;
  addons = inputs.firefox-addons.packages.${pkgs.system};
  firefoxWrapped = pkgs.wrapFirefox pkgs.firefox-unwrapped {
    forceWayland = true;
    extraPolicies = {
      CaptivePortal = false;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DisableFirefoxAccounts = true;
      FirefoxHome = {
        Pocket = false;
        Snippets = false;
      };
      UserMessaging = {
        ExtensionRecommendations = false;
        SkipOnboarding = true;
      };
    };
    extraPrefs = ''
      // Show more ssl cert infos
      lockPref("security.identityblock.show_extended_validation", true);
    '';
  };
in {
  options.conf.applications.firefox.enable = lib.mkEnableOption "Firefox";
  config.home-manager.users.${config.conf.users.user} = lib.mkIf cfg.enable {
    programs.browserpass.enable = true;
    programs.firefox = {
      enable = true;
      #   package = pkgs.librewolf;
      extensions = with addons; [
        ublock-origin
        bitwarden
        bypass-paywalls-clean
        i-dont-care-about-cookies
        auto-tab-discard
        no-pdf-download
        save-page-we
      ];
      profiles.${config.conf.users.user} = {
        bookmarks = {};
        settings = {
          "browser.startup.homepage" = "https://start.duckduckgo.com";
          "identity.fxaccounts.enabled" = false;
          "privacy.trackingprotection.enabled" = true;
          "dom.security.https_only_mode" = true;
          "signon.rememberSignons" = false;
          "browser.topsites.blockedSponsors" = ''["amazon"]'';
          "browser.shell.checkDefaultBrowser" = false;
          "browser.shell.defaultBrowserCheckCount" = 1;
          "browser.disableResetPrompt" = true;
          #  "browser.uiCustomization.state" = ''{"placements":{"widget-overflow-fixed-list":["ublock0_raymondhill_net-browser-action"],"nav-bar":["back-button","forward-button","stop-reload-button","home-button","urlbar-container","downloads-button","library-button"],"toolbar-menubar":["menubar-items"],"TabsToolbar":["tabbrowser-tabs","new-tab-button","alltabs-button"],"PersonalToolbar":["import-button","personal-bookmarks"]},"seen":["save-to-pocket-button","developer-button","ublock0_raymondhill_net-browser-action"],"dirtyAreaCache":["nav-bar","PersonalToolbar","toolbar-menubar","TabsToolbar","widget-overflow-fixed-list"],"currentVersion":17,"newElementCount":3}'';
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "browser.ctrlTab.sortByRecentlyUsed" = true;
        };
      };
    };

    home.persistence = {
      "/persist/home/${config.conf.users.user}".directories = [".mozilla/firefox"];
    };
  };
}
