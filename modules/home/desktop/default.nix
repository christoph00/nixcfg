{
  lib,
  config,
  pkgs,
  inputs,
  osConfig ? {},
  ...
}: let
  inherit (lib) types mkIf mkDefault mkMerge;
  inherit (lib.chr) mkOpt;

  cfg = config.chr.desktop;
in {
  imports = [
    inputs.nix-colors.homeManagerModules.default
  ];
  options.chr.desktop.enable = mkOpt types.bool false "Enable Desktop Config.";

  config = mkIf cfg.enable {
    colorscheme = inputs.nix-colors.colorSchemes.tokyo-city-terminal-light;


    home.packages = with pkgs; [
      brightnessctl
      coreutils

      #(inputs'.eww.packages.default.override {withWayland = true;})

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

      themechanger

      gnome.gnome-keyring

      darktable

      nix-init

      nixd

      pcmanfm
      webcord

      vulkan-tools
      glxinfo

      wlsunset
      wl-clipboard

      peazip
    ];
  };
}
