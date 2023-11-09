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
    programs.adb.enable = true;

    chr.home.extraOptions = {
      home.packages = with pkgs; [
        brightnessctl
        coreutils

        libnotify
        playerctl
        wireplumber
        wtype
        pavucontrol
        vlc

        xdg-utils
        solaar

        pciutils

        usbimager

        themechanger

        typst

        gnome.gnome-keyring

        nix-init

        nixd

        vulkan-tools
        glxinfo

        wlsunset
        wl-clipboard

        peazip

        jetbrains.goland

        jetbrains.webstorm

        # chr.jetbrains-fleet

        heimdall-gui

        codeium
      ];
    };
  };
}
