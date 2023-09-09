{
  pkgs,
  lib,
  inputs,
  config,
  ...
}: let
  # addons = inputs.firefox-addons.packages.${pkgs.system};
  inherit (config.colorscheme) colors;
in {
  programs.browserpass.enable = true;
  programs.firefox = {
    enable = true;
    #   package = pkgs.librewolf;
    # extensions = with addons; [
    #   ublock-origin
    #   bitwarden
    #   bypass-paywalls-clean
    #   i-dont-care-about-cookies
    #   auto-tab-discard
    #   no-pdf-download
    #   save-page-we
    #   privacy-redirect
    #   startpage-private-search
    #   violentmonkey
    #   user-agent-string-switcher
    # ];
    profiles.christoph = {
      bookmarks = {};
      settings = {
        "identity.fxaccounts.enabled" = false;
        "signon.rememberSignons" = false;
        "browser.topsites.blockedSponsors" = ''["amazon"]'';
        "browser.shell.checkDefaultBrowser" = false;
        "browser.shell.defaultBrowserCheckCount" = 1;
        "browser.disableResetPrompt" = true;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "browser.ctrlTab.sortByRecentlyUsed" = true;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "general.smoothScroll" = true;
        "gfx.canvas.accelerated" = true;
        "gfx.webrender.enabled" = true;
        "media.hardware-video-decoding.force-enabled" = true;
        "media.rdd-ffmpeg.enabled" = true;
        "widget.dmabuf.force-enabled" = true;
        "widget.use-xdg-desktop-portal" = true;
        # "font.name.monospace.x-western" = "${config.fontProfiles.monospace.family}";
        # "font.name.sans-serif.x-western" = "${config.fontProfiles.regular.family}";
        # "font.name.serif.x-western" = "${config.fontProfiles.regular.family}";
      };
    };
  };

  # xdg.mimeApps.defaultApplications = {
  #   "text/html" = ["firefox.desktop"];
  #   "text/xml" = ["firefox.desktop"];
  #   "x-scheme-handler/http" = ["firefox.desktop"];
  #   "x-scheme-handler/https" = ["firefox.desktop"];
  # };

  # home.sessionVariables.BROWSER = "firefox";
}
