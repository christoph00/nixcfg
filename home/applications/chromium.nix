{
  config,
  pkgs,
  ...
}: let
  vivaldi-css = with config.colorscheme.colors; ''
      :root {
        --base00: #${base00}; # ----
        --base01: #${base01}; # ---
        --base02: #${base02}; # --
        --base03: #${base03}; # -
        --base04: #${base04}; # +
        --base05: #${base05}; # ++
        --base06: #${base06}; # +++
        --base07: #${base07}; # ++++
        --base08: #${base08}; # red
        --base09: #${base09}; # orange
        --base0A: #${base0A}; # yellow
        --base0B: #${base0B}; # green
        --base0C: #${base0C}; # aqua
        --base0D: #${base0D}; # blue
        --base0E: #${base0E}; # purple
        --base0F: #${base0F}; # brown
      }

      * {
        font-family: ${config.fontProfiles.regular.family};
      }

      #browser, #browser + div, #browser + div + div {
       font-size: 15px;
      }

      .bookmark-bar .observer button {
         font-size: 14px;
         font-weight: bold;
      }
      .tab-strip .tab-header {
       font-size: 15px;
      }

      .button-toolbar.home { display: none }

      /*
      * Remove the gradient from the titlebar, keeping only the lighter color.
      * Better CSS thanks to potmeklecbohdan - https://forum.vivaldi.net/post/268276
      */

      .tabs-top.color-behind-tabs-on #tabs-container {
        background: var(--colorAccentBg) !important;
      }

      .toolbar-mainbar.toolbar-wrap {
        /* makes the extensions popup look better */
        border-radius: 10px;
        position: absolute !important;
        background-color: var(--colorAccentBg);
      }
      button[title="Speed Dial Generator"], button[title="Modern scrollbar"], button[title="Charcoal: Dark Mode for Messenger"], button[title="Cookie Notice Blocker"], button[title="Angular DevTools"] {
        /* hides the extensions of the given title */
        display: none !important;
      }

      .button-toolbar>button {
        border-radius: var(--radius) !important;
        /* adaptes the border of the toolbar buttons to the selected theme */
      }

      .toolbar-insideinput>.pageload>div {
        display: none;
        /* hides the loading progress */
      }

      /* use correct accent color */
    .tab-indicator.active {
      background-color: var(--colorAccentBg) !important;
    }

    .tab.active {
      font-weight: bold;
    }

    #switch {
      background-color: var(--colorBorder);
    }

    .tab .close {
      border-radius: 100%;
    }

    #webview-container:has(#webpage-stack .mosaic.visible) {
      box-shadow: 0 0 0 8px var(--colorBorder), inset 0 0 0 4px var(--colorBorder);
    }

    .mosaic-split .mosaic-split-line, .mosaic-split .mosaic-split-line::before, .mosaic-split .mosaic-split-line::after {
      background-color: var(--colorBorder)
    }

  '';
in {
  programs.chromium = {
    enable = true;
    #package = pkgs.vivaldi;
    package = pkgs.vivaldi.override {
      proprietaryCodecs = true;
      enableWidevine = true;
      vivaldi-ffmpeg-codecs = pkgs.vivaldi-ffmpeg-codecs;
      vivaldi-widevine = pkgs.vivaldi-widevine;
    };
    extensions = [
      {id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";} # Ublock Origin
      {id = "jhnleheckmknfcgijgkadoemagpecfol";} # Auto-Tab-Discard
      {id = "nngceckbapebfimnlniiiahkandclblb";} # Bitwarden
      {
        id = "dcpihecpambacapedldabdbpakmachpb";
        updateUrl = "https://raw.githubusercontent.com/iamadamdev/bypass-paywalls-chrome/master/updates.xml";
      }
      {id = "pmcmeagblkinmogikoikkdjiligflglb";} # Privacy Redirect
      {id = "hfmolcaikbnbminafcmeiejglbeelilh";} # CNL Decryptor
      {id = "ncgbkkljbaojkhljombpjejedphfhdjj";} # User Agent Switcher
    ];
    commandLineArgs = [
      "--enable-features=UseOzonePlatform"
      "--ozone-platform=wayland"
      "--ignore-gpu-blocklist"
    ];
  };

  home.packages = [pkgs.vivaldi-widevine pkgs.vivaldi-ffmpeg-codecs];

  home.persistence = {
    "/nix/persist/home/christoph".directories = [".config/chromium/Default" ".config/BraveSoftware/Brave-Browser/Default" ".config/vivaldi/Default"];
  };
  home.file.".config/vivaldi/UserCSS/theme.css".text = vivaldi-css;
}
