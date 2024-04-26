{
  options,
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.desktop.plasma;
in {
  options.chr.desktop.plasma = with types; {
    enable = mkBoolOpt false "Whether or not to enable Plasma.";
  };

  config = mkIf cfg.enable {
    #    security.pam.services.greetd.enableKwallet = true;

    environment.sessionVariables.NIXOS_OZONE_WL = "1";
    hardware.sane.enable = true;
    environment.systemPackages = with pkgs; [
      wl-clipboard
      kdePackages.plasma-thunderbolt
      kdePackages.kcalc
      kdePackages.kdenlive
      kdePackages.skanlite
    ];

    services.rustdesk-server = {
      enable = true;
      relayIP = "0.0.0.0";
    };

    services.xserver = {
      enable = true;
      displayManager.sddm.wayland.enable = true;
      displayManager.sddm.enable = true;
    };
    services.desktopManager.plasma6.enable = true;

    programs = {
      kdeconnect.enable = true;
      partition-manager.enable = true;

      # Workaround for badly themed GTK apps on Wayland
      dconf.enable = true;
    };
  };
}
