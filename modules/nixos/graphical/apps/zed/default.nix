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
  cfg = config.internal.graphical.apps.zed;

  # zed-fhs = pkgs.buildFHSUserEnv {
  #   name = "zed";
  #   targetPkgs = pkgs: with pkgs; [ zed-editor ];
  #   runScript = "zed";
  # };
in
{

  options.internal.graphical.apps.zed = {
    enable = mkBoolOpt config.internal.isGraphical "Enable Zed.";
  };

  config = mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      zed-editor
      nixd
      intelephense
      vscode-langservers-extracted
    ];

  };

}
