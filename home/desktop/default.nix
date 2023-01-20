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
  mkWallpaper = {
    scheme,
    width,
    height,
    logoScale,
  }:
    pkgs.stdenv.mkDerivation {
      name = "generated-nix-wallpaper-${scheme.slug}.png";
      src = pkgs.writeTextFile {
        name = "template.svg";
        text = ''
          <svg width="${toString width}" height="${
            toString height
          }" version="1.1" xmlns="http://www.w3.org/2000/svg">
            <rect width="${toString width}" height="${
            toString height
          }" fill="#${scheme.colors.base00}"/>
            <svg x="${toString (width / 2 - (logoScale * 50))}" y="${
            toString (height / 2 - (logoScale * 50))
          }" version="1.1" xmlns="http://www.w3.org/2000/svg">
              <g transform="scale(${toString logoScale})">
                <g transform="matrix(.19936 0 0 .19936 80.161 27.828)">
                  <path d="m-53.275 105.84-122.2-211.68 56.157-0.5268 32.624 56.869 32.856-56.565 27.902 0.011 14.291 24.69-46.81 80.49 33.229 57.826zm-142.26 92.748 244.42 0.012-27.622 48.897-65.562-0.1813 32.559 56.737-13.961 24.158-28.528 0.031-46.301-80.784-66.693-0.1359zm-9.3752-169.2-122.22 211.67-28.535-48.37 32.938-56.688-65.415-0.1717-13.942-24.169 14.237-24.721 93.111 0.2937 33.464-57.69z" fill="#${scheme.colors.base0C}"/>
                  <path d="m-97.659 193.01 122.22-211.67 28.535 48.37-32.938 56.688 65.415 0.1716 13.941 24.169-14.237 24.721-93.111-0.2937-33.464 57.69zm-9.5985-169.65-244.42-0.012 27.622-48.897 65.562 0.1813-32.559-56.737 13.961-24.158 28.528-0.031 46.301 80.784 66.693 0.1359zm-141.76 93.224 122.2 211.68-56.157 0.5268-32.624-56.869-32.856 56.565-27.902-0.011-14.291-24.69 46.81-80.49-33.229-57.826z" fill="#${scheme.colors.base0D}" style="isolation:auto;mix-blend-mode:normal"/>
                </g>
              </g>
            </svg>
          </svg>
        '';
      };
      buildInputs = with pkgs; [inkscape];
      unpackPhase = "true";
      buildPhase = ''
        inkscape --export-type="png" $src -w ${toString width} -h ${
          toString height
        } -o wallpaper.png
      '';
      installPhase = "install -Dm0644 wallpaper.png $out";
    };
in {
  imports = [
    ./gtk.nix
    #./plasma.nix
    ./hyprland.nix
    ./waybar.nix
    ./wayvnc.nix
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

    xdg-utils

    google-chrome
  ];

  colorscheme = inputs.nix-colors.colorSchemes.rose-pine;
  wallpaper = lib.mkDefault (mkWallpaper
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
        prompt = "· ";
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
      border = {
        width = 2;
      };
    };
  };

  services.dunst = {
    enable = true;
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
    settings = with config.colorscheme.colors; {
      global = {
        width = 300;
        origin = "top-center";
        alignment = "left";
        vertical_alignment = "center";
        ellipsize = "middle";
        offset = "15x15";
        padding = 18;
        horizontal_padding = 18;
        text_icon_padding = 18;
        progress_bar = true;
        progress_bar_height = 8;
        progress_bar_frame_width = 1;
        progress_bar_min_width = 150;
        progress_bar_max_width = 300;
        format = "<span size='x-large' font_desc='${config.fontProfiles.monospace.family} 9' weight='bold' foreground='#${base04}'>%a</span>\\n%s\\n%b";
        frame_color = "#${base01}";
        font = "${config.fontProfiles.monospace.family} 11";
      };
      urgency_low = {
        timeout = 3;
        background = "#${base00}";
        foreground = "#${base04}";
        highlight = "#${base0E}";
      };
      urgency_normal = {
        timeout = 6;
        background = "#${base00}";
        foreground = "#${base04}";
        highlight = "#${base08}";
      };
      urgency_critical = {
        timeout = 0;
        background = "#${base00}";
        foreground = "#${base04}";
        highlight = "#${base0C}";
      };

      brightness = {
        summary = "󰃞 Light";
        set_stack_tag = "brightness";
      };
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
