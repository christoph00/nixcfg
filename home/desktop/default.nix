{
  pkgs,
  lib,
  config,
  system,
  inputs,
  ...
}: let
  inherit (inputs.nix-colors.lib-contrib {inherit pkgs;}) nixWallpaperFromScheme;
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

    gnome.nautilus

    gfn-electron
    moonlight-qt

    obsidian
  ];

  colorscheme = inputs.nix-colors.colorSchemes.ayu-mirage;
  wallpaper = lib.mkDefault (nixWallpaperFromScheme
    {
      scheme = config.colorscheme;
      width = 1920;
      height = 1080;
      logoScale = 4;
    });
  home.file.".colorscheme".text = config.colorscheme.slug;

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
