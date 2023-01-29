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
