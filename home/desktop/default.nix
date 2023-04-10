{
  pkgs,
  lib,
  config,
  system,
  inputs,
  ...
}: let
  inherit (inputs.nix-colors.lib-contrib {inherit pkgs;}) nixWallpaperFromScheme;
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
    #./sway.nix
    #./wayvnc.nix
    ./rofi.nix
    #./xfce.nix
    #./labwc.nix
    #./river.nix
    ./idle.nix
    # ./ironbar.nix
    ./eww.nix
    #./sfwbar.nix
    # ./waybar.nix
  ];

  home.packages = with pkgs; [
    libnotify
    playerctl
    wireplumber
    wtype
    pavucontrol
    vlc

    xdg-utils
    xdg-desktop-portal
    xdg-desktop-portal-wlr
    solaar

    pciutils

    foot

    kanshi
  ];

  colorscheme = inputs.nix-colors.colorSchemes.rose-pine-dawn;
  wallpaper = lib.mkDefault (mkWallpaper
    {
      scheme = config.colorscheme;
      width = 1920;
      height = 1080;
      logoScale = 4;
    });
  xdg.dataFile."colorscheme".text = config.colorscheme.slug;
  xdg.dataFile."wallpaper.png".source = config.wallpaper;

  home.sessionVariables = {
    #BROWSER = "firefox";
    #TERMINAL = "footclient";
    NIXPKGS_ALLOW_UNFREE = 1;
  };

  #xdg.mimeApps.enable = true;
  #xdg.mimeApps.associations.added = associations;
  #xdg.mimeApps.defaultApplications = associations;

  services.rclone = {
    enable = true;
    config = "/run/agenix/rclone-conf";
    mounts = {
      nas = {
        from = "nas:";
        to = "/home/christoph/NAS";
      };
    };
  };

  fontProfiles = {
    enable = true;
    monospace = {
      family = "Agave Nerd Font";
      package = pkgs.nerdfonts.override {fonts = ["Agave"];};
    };
    regular = {
      family = "Fira Sans";
      package = pkgs.fira;
    };
  };

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "true";
    QT_QPA_PLATFORM = "wayland";
    LIBSEAT_BACKEND = "logind";
    GTK_THEME = "${config.gtk.theme.name}";
    XCURSOR_THEME = "${config.gtk.cursorTheme.name}";
    XCURSOR_SIZE = "${toString config.gtk.cursorTheme.size}";
  };

  dconf.enable = true;

  services.gammastep = {
    enable = true;
    latitude = "52.3";
    longitude = "9.7";
  };
}
