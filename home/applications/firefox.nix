{
  pkgs,
  lib,
  inputs,
  config,
  ...
}: let
  addons = inputs.firefox-addons.packages.${pkgs.system};
in {
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
      privacy-redirect
    ];
    profiles.christoph = {
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
        "browser.uiCustomization.state" = ''{"placements":{"widget-overflow-fixed-list":["ublock0_raymondhill_net-browser-action"],"nav-bar":["back-button","forward-button","stop-reload-button","home-button","urlbar-container","downloads-button","library-button"],"toolbar-menubar":["menubar-items"],"TabsToolbar":["tabbrowser-tabs","new-tab-button","alltabs-button"],"PersonalToolbar":["import-button","personal-bookmarks"]},"seen":["save-to-pocket-button","developer-button","ublock0_raymondhill_net-browser-action"],"dirtyAreaCache":["nav-bar","PersonalToolbar","toolbar-menubar","TabsToolbar","widget-overflow-fixed-list"],"currentVersion":17,"newElementCount":3}'';
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "svg.context-properties.content.enabled" = true;
        "browser.ctrlTab.sortByRecentlyUsed" = true;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "general.smoothScroll" = true;
        "gfx.canvas.accelerated" = true;
        "gfx.webrender.enabled" = true;
        "gfx.x11-egl.force-enabled" = true;
        "layers.acceleration.force-enabled" = true;
        "media.av1.enabled" = false;
        "media.ffmpeg.vaapi.enabled" = true;
        "media.hardware-video-decoding.force-enabled" = true;
        "media.rdd-ffmpeg.enabled" = true;
        "widget.dmabuf.force-enabled" = true;
        "widget.use-xdg-desktop-portal" = true;

        "gnomeTheme.hideSingleTab" = true;
        "gnomeTheme.systemIcons" = true;
      };
      userChrome = ''
        @import "${pkgs.firefox-gnome-theme}/share/firefox-gnome-theme/userChrome.css";
      '';

      userContent = ''
        @import "${pkgs.firefox-gnome-theme}/share/firefox-gnome-theme/userContent.css";
      '';

      extraConfig = builtins.readFile "${pkgs.firefox-gnome-theme}/share/firefox-gnome-theme/configuration/user.js";
    };
  };

  xdg.mimeApps.defaultApplications = {
    "text/html" = ["firefox.desktop"];
    "text/xml" = ["firefox.desktop"];
    "x-scheme-handler/http" = ["firefox.desktop"];
    "x-scheme-handler/https" = ["firefox.desktop"];
  };

  home.sessionVariables.BROWSER = "firefox";

  home.persistence = {
    "/persist/home/christoph".directories = [".mozilla/firefox"];
  };
}
