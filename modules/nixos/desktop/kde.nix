
{
  lib,
  flake,
  config,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (flake.lib) mkBoolOpt;
in
{

  options.desktop.kde = {
    enable = mkBoolOpt false;
  };

  config = mkIf config.desktop.kde.enable {
    services.desktopManager.plasma6.enable = true;
    programs.firefox.nativeMessagingHosts.packages = [ pkgs.kdePackages.plasma-browser-integration ];

    security.pam.services.kwallet = {
      name = "kwallet";
      enableKwallet = true;
    };

    home.packages =
    with pkgs;
    with kdePackages; [
      plasma-browser-integration
      kcalc
      krfb
      krdc
      ksshaskpass
      plasma-panel-colorizer
      plasma-vault
      purpose
    ];

  };
}
