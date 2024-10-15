{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib
, # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs
, # You also have access to your flake's inputs.
  config
, inputs
, ...
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
          discord = { basePackage = pkgs.vesktop; };
          obsidian = { basePackage = pkgs.obsidian; };
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

    environment.systemPackages = [
      pkgs.zen-browser
      pkgs.zed-editor
      pkgs.vscode
      pkgs.kitty
      pkgs.foot
      pkgs.anyrun
      pkgs.moonlight-qt
      pkgs.floorp
      pkgs.librewolf
      pkgs.libreoffice-fresh
      pkgs.rio
      pkgs.gimp
      pkgs.wezterm

      wrapped
      pkgs.gthumb
      pkgs.gtkimageview
      pkgs.digikam

      pkgs.qownnotes
      pkgs.rssguard
    ];

  };

}
