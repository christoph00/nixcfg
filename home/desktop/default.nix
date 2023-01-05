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

  colorscheme = inputs.nix-colors.colorSchemes.tokyo-city-terminal-dark;
  wallpaper = lib.mkDefault (nixWallpaperFromScheme
    {
      scheme = config.colorscheme;
      width = 1920;
      height = 1080;
      logoScale = 4;
    });
  home.file.".colorscheme".text = config.colorscheme.slug;

  services.dunst = {
    enable = true;
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
  };
  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "true";
    QT_QPA_PLATFORM = "wayland";
    LIBSEAT_BACKEND = "logind";
  };

  dconf.enable = true;
}
