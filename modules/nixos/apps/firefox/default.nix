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
    extraConfig =
      mkOpt str "" "Extra configuration for the user profile JS file.";
    userChrome =
      mkOpt str "" "Extra configuration for the user chrome CSS file.";
    settings = mkOpt attrs defaultSettings "Settings to apply to the profile.";
  };

  config = mkIf cfg.enable {
    chr.home = {
      extraOptions = {
        programs.firefox = {
          enable = true;
          package = pkgs.firefox-beta;
          profiles.${config.chr.user.name} = {
            inherit (cfg) extraConfig userChrome settings;
            id = 0;
            name = config.chr.user.name;
            extensions = with inputs.firefox-addons; [
              aria2-integration
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
