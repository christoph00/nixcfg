{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib,
  # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs,
  # You also have access to your flake's inputs.
  config,
  inputs,
  ...
}:

with builtins;
with lib;
with lib.internal;

let
  cfg = config.internal.graphical.apps.misc;

  wrapped = inputs.wrapper-manager.lib.build {
    inherit pkgs;
    modules = [
      {
        wrappers = {
          discord = {
            basePackage = pkgs.vesktop;
          };
          obsidian = {
            basePackage = pkgs.obsidian;
          };

        };
      }
    ];
  };

in
{

  options.internal.graphical.apps.misc = {
    enable = mkBoolOpt config.internal.isGraphical "Enable the misc desktop apps.";
  };

  config = mkIf cfg.enable {
    environment.sessionVariables.OPEN_AI_API_URL = "https://api.perplexity.ai";

    environment.systemPackages = [
      pkgs.vscode
      pkgs.kitty
      pkgs.anyrun
      pkgs.moonlight-qt

      pkgs.libreoffice-fresh
      pkgs.gimp

      pkgs.keepassxc

      pkgs.ghostty

      wrapped
      pkgs.gthumb
      pkgs.gtkimageview
      # pkgs.digikam

      pkgs.networkmanagerapplet

      pkgs.nextcloud-client

      pkgs.kdePackages.okular

      pkgs.agenix

      pkgs.nemo

      pkgs.nixd
      pkgs.gopls
      pkgs.go

      pkgs.planify

      inputs.zen-browser.packages.${pkgs.system}.default
    ];

  };

}
