{
  pkgs,
  lib,
  config,
  system,
  inputs,
  ...
}: let
  inherit (inputs.nix-colors.lib-contrib {inherit pkgs;}) nixWallpaperFromScheme;
  browser = ["firefox.desktop"];
  associations = {
    "text/html" = browser;
    "x-scheme-handler/http" = browser;
    "x-scheme-handler/https" = browser;
    "x-scheme-handler/ftp" = browser;
    "x-scheme-handler/chrome" = browser;
    "x-scheme-handler/about" = browser;
    "x-scheme-handler/unknown" = browser;
    "application/x-extension-htm" = browser;
    "application/x-extension-html" = browser;
    "application/x-extension-shtml" = browser;
    "application/xhtml+xml" = browser;
    "application/x-extension-xhtml" = browser;
    "application/x-extension-xht" = browser;
    "image/*" = "org.gnome.eog.desktop";

    #"text/*" = [ "emacs.desktop" ];
    "audio/*" = ["vlc.desktop"];
    "video/*" = ["vlc.dekstop"];
    #"image/*" = [ "ahoviewer.desktop" ];
    #"text/calendar" = [ "thunderbird.desktop" ]; # ".ics"  iCalendar format
    "application/json" = browser; # ".json"  JSON format
    "application/pdf" = browser; # ".pdf"  Adobe Portable Document Format (PDF)
    #"x-scheme-handler/tg" = "userapp-Telegram Desktop-95VAQ1.desktop";
  };
in {
  imports = [
    ./gtk.nix
    #./plasma.nix
    ./hyprland.nix
    ./waybar.nix
  ];

  home.packages = with pkgs; [
    imv
    libnotify
    playerctl
    wf-recorder
    wl-clipboard
    wlr-randr
    wireplumber
    wofi

    wlogout
    clipman
    wdisplays
    kanshi
    wob

    gnome3.nautilus
    gnome3.eog

    pavucontrol

    vlc

    gfn-electron
    moonlight-qt

    obsidian

    xdg-utils
  ];

  colorscheme = inputs.nix-colors.colorSchemes.rose-pine;
  wallpaper = lib.mkDefault (nixWallpaperFromScheme
    {
      scheme = config.colorscheme;
      width = 1920;
      height = 1080;
      logoScale = 4;
    });
  home.file.".colorscheme".text = config.colorscheme.slug;

  home.sessionVariables = {
    BROWSER = "firefox";
    TERMINAL = "footclient";
    NIXPKGS_ALLOW_UNFREE = 1;
  };

  xdg.mimeApps.enable = true;
  xdg.mimeApps.associations.added = associations;
  xdg.mimeApps.defaultApplications = associations;

  home.persistence = {
    "/nix/persist/home/christoph".directories = [".config/libreoffice" ".config/GeForce\ NOW"];
  };

  fontProfiles = {
    enable = true;
    monospace = {
      family = "Agave Nerd Font";
      package = pkgs.nerdfonts.override {fonts = ["Agave"];};
    };
    regular = {
      family = "Noto Sans";
      package = pkgs.noto-fonts;
    };
  };

  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        dpi-aware = "no";
        font = "${config.fontProfiles.regular.family}:size=24";
        fields = "name,generic,comment,categories,filename,keywords";
        layer = "overlay";
        lines = 5;
      };
      colors = with config.colorscheme.colors; {
        background = "${base00}dd";
        text = "${base05}ff";
        match = "${base0D}ff";
        selection = "${base05}dd";
        selection-text = "${base00}ff";
        selection-match = "${base0D}ff";
        border = "${base03}ff";
      };
    };
  };

  services.dunst = {
    enable = true;
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
  };

  services.gammastep = {
    enable = true;
    provider = "manual";
    duskTime = "18:35-20:15";
    dawnTime = "6:00-7:45";
    temperature = {
      day = 5500;
      night = 3700;
    };
    settings = {
      general.adjustment-method = "wayland";
    };
  };

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "true";
    QT_QPA_PLATFORM = "wayland";
    LIBSEAT_BACKEND = "logind";
  };

  dconf.enable = true;
}
