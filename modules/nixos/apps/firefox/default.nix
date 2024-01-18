{
  options,
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.apps.firefox;
  defaultSettings = {
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
  };
in {
  options.chr.apps.firefox = with types; {
    enable = mkBoolOpt config.chr.desktop.enable "Whether or not to enable Firefox.";
    settings = mkOpt attrs defaultSettings "Settings to apply to the profile.";
  };

  config = mkIf cfg.enable {
    chr.home = {
      extraOptions = {
        programs.firefox = {
          enable = true;
          package = pkgs.firefox-beta;
          profiles.${config.chr.user.name} = {
            inherit (cfg) settings;
            id = 0;
            name = config.chr.user.name;
            extraConfig = "user_pref(\"toolkit.legacyUserProfileCustomizations.stylesheets\", true)";
            userChrome = lib.concatMapStringsSep "\n" builtins.readFile [
              "${pkgs.chr.firefox-cascade}/includes/cascade-config.css"
              "${pkgs.chr.firefox-cascade}/includes/cascade-colours.css"
              "${pkgs.chr.firefox-cascade}/includes/cascade-layout.css"
              "${pkgs.chr.firefox-cascade}/includes/cascade-responsive.css"
              "${pkgs.chr.firefox-cascade}/includes/cascade-floating-panel.css"
              "${pkgs.chr.firefox-cascade}/includes/cascade-nav-bar.css"
              "${pkgs.chr.firefox-cascade}/includes/cascade-tabs.css"
            ];
            extensions = with inputs.firefox-addons.packages."${pkgs.system}"; [
              clearurls
              decentraleyes
              bitwarden
              no-pdf-download
              ublock-origin
            ];
          };
        };
      };
    };
  };
}
