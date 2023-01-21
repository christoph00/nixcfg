{
  pkgs,
  lib,
  inputs,
  config,
  ...
}: let
  addons = inputs.firefox-addons.packages.${pkgs.system};
  inherit (config.colorscheme) colors;
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
      startpage-private-search
      violentmonkey
    ];
    profiles.christoph = {
      bookmarks = {};
      settings = {
        #  "browser.search.defaultenginename" = "Startpage.com - English";
        #  "browser.search.selectedEngine" = "Startpage.com - English";
        #  "browser.urlbar.placeholderName" = "Startpage.com - English";
        #  "browser.search.region" = "DE";
        "browser.startup.homepage" = "https://www.startpage.com/do/mypage.pl?prfe=c4c2ccf1e58b0f22b47e301bfe7c441392f33167428c28680d636dc2a424166d6e712c02f082a97c0107b9a7056212cdd71dbd7d34d40581d8e1afb99b5a45ffcd21d1fc3c5955a79e36306699";
        "identity.fxaccounts.enabled" = false;
        "privacy.trackingprotection.enabled" = true;
        "dom.security.https_only_mode" = true;
        "signon.rememberSignons" = false;
        "browser.topsites.blockedSponsors" = ''["amazon"]'';
        "browser.shell.checkDefaultBrowser" = false;
        "browser.shell.defaultBrowserCheckCount" = 1;
        "browser.disableResetPrompt" = true;
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
        "font.name.monospace.x-western" = "${config.fontProfiles.monospace.family}";
        "font.name.sans-serif.x-western" = "${config.fontProfiles.regular.family}";
        "font.name.serif.x-western" = "${config.fontProfiles.regular.family}";
        "gnomeTheme.systemIcons" = true;
        "gnomeTheme.hideSingleTab" = true;
      };
      userChrome = ''
        @import "${pkgs.firefox-gnome-theme}/share/firefox-gnome-theme/userChrome.css";

        @media (prefers-color-scheme: dark) {
         :root {

          --gnome-browser-before-load-background: #${colors.base00};
          --gnome-headerbar-background: #${colors.base00};

          --gnome-accent: #${colors.base08};

         }
        }
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
    "/nix/persist/home/christoph".directories = [".mozilla/firefox"];
  };
}
