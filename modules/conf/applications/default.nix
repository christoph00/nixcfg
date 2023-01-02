{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.conf.applications;
in {
  imports = [./wezterm.nix ./emacs.nix ./vivaldi.nix ./firefox.nix];

  options.conf.applications = {
    enable = mkEnableOption "applications Config";
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.conf.users.user} = lib.mkMerge [
      {
        programs.wezterm = {
          enable = true;
        };
        programs.zathura = {
          enable = true;
          options = {
            selection-clipboard = "clipboard";
            recolor = true;
          };
        };

        programs.chromium = {
          enable = true;
          package = pkgs.chromium;

          commandLineArgs = lib.concatStringsSep " " [
            "--disk-cache=$XDG_RUNTIME_DIR/chromium-cache"
            "--no-default-browser-check"
            "--no-service-autorun"
            "--disable-features=PreloadMediaEngagementData,MediaEngagementBypassAutoplayPolicies"
            # Autoplay policy
            "--document-user-activation-required"
            # Enable Wayland support
            "--enable-features=UseOzonePlatform"
            "--ozone-platform-hint=auto"
            # Disable global Google login
            "--disable-sync-preferences"
            # Reader mode
            "--enable-reader-mode"
            "--enable-dom-distiller"
            # Dark mode
            "--enable-features=WebUIDarkMode"
            # Security stuff
            "--disable-reading-from-canvas"
            "--no-pings"
            "--no-first-run"
            "--no-experiments"
            "--no-crash-upload"
            # Store secrets in Gnome's Keyring
            "--password-store=gnome"
            # Chromecast
            "--load-media-router-component-extension"
            "--disable-wake-on-wifi"
            "--disable-breakpad"
            "--disable-sync"
            "--disable-speech-api"
            "--disable-speech-synthesis-api"
            # GPU stuff
            "--enable-features=UseOzonePlatform,VaapiVideoDecoder"
            "--ignore-gpu-blocklist"
            "--enable-gpu-rasterization"
            "--disable-gpu-driver-bug-workarounds"
            "--disable-background-networking"
            "--disable-reading-from-canvas"
            "--enable-accelerated-video-decode"
            "--use-gl=egl" # / desktop
            "--enable-zero-copy"
          ];

          extensions = [
            {id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";} # ublock origin
            {id = "nngceckbapebfimnlniiiahkandclblb";} # bitwarden
            {id = "pmcmeagblkinmogikoikkdjiligflglb";} # privacy redirect
            {id = "chgiddljhokfbppnhfphdabejocpopgk";} # gfn unlocker
          ];
        };

        home.persistence = {
          "/persist/home/christoph".directories = [".config/chromium/Default" ".local/share/keyrings"];
        };

        services.gnome-keyring = {
          enable = true;
          components = ["secrets" "ssh"];
        };

        services.playerctld = {
          enable = true;
        };
      }
    ];
  };
}
