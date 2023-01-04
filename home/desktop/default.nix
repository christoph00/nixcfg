{
  pkgs,
  lib,
  config,
  system,
  inputs,
  ...
}: {
  imports = [
    #    ./hyprland.nix
    #    ./waybar.nix
    ./gtk.nix
    ./plasma.nix
    ./hyprland.nix
  ];

  colorScheme = inputs.nix-colors.colorSchemes.dracula;

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "true";
    QT_QPA_PLATFORM = "wayland";
    LIBSEAT_BACKEND = "logind";
  };

  dconf.enable = true;
}
