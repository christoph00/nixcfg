{
  inputs,
  pkgs,
  osConfig,
  lib,
  ...
}: {
  imports = [./hyprland.nix ./apps];
  config = lib.mkIf (builtins.elem osConfig.nos.type ["desktop" "laptop"]) {
    colorscheme = inputs.nix-colors.colorSchemes.tokyo-city-terminal-light;

    home.packages = with pkgs; [
      brightnessctl
      coreutils

      (inputs'.eww.packages.default.override {withWayland = true;})

      libnotify
      playerctl
      wireplumber
      wtype
      pavucontrol
      vlc

      xdg-utils
      solaar

      pciutils

      foot

      kanshi

      usbimager

      gimp-with-plugins
      inkscape

      inputs'.agenix.packages.default

      themechanger

      gnome.gnome-keyring

      darktable

      nix-init

      nixd

      pcmanfm
      webcord

      openBase16
      # gpt4all
    ];
  };
}
