{
  pkgs,
  lib,
  config,
  system,
  inputs,
  ...
}: {
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
  ];

  colorScheme = inputs.nix-colors.colorSchemes.dracula;

  services.dunst = {
    enable = true;
  };
  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "true";
    QT_QPA_PLATFORM = "wayland";
    LIBSEAT_BACKEND = "logind";
  };

  dconf.enable = true;
}
