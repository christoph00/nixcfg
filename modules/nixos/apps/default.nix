{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.apps;
in {
  options.chr.apps = with types; {
    enable = mkBoolOpt' config.chr.desktop.enable;
  };

  config = mkIf cfg.enable {
    chr.home.extraOptions = {
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

        libreoffice-qt
      ];
    };
  };
}
