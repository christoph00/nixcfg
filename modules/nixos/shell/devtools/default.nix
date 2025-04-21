{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
with lib.internal;
let
  cfg = config.internal.shell.devtools;
  wrapped = inputs.wrapper-manager.lib.build {
    inherit pkgs;
    modules = [
      {
        wrappers = {
          aider = {
            basePackage = inputs.aider-nix.packages.${pkgs.system}.aider-chat.override {
              withAllFeatures = true;
              withPlaywright = true;
              withBrowser = true;
              withHelp = true;
            };
            flags = [
              "--env-file"
              "${config.age.secrets.aider-env.path}"
            ];
          };
        };
      }
    ];
  };
in
{
  options.internal.shell.devtools = with types; {
    enable = mkBoolOpt config.internal.isGraphical "Whether or not to configure neovim config.";
  };

  config = mkIf cfg.enable {

    age.secrets.aider-env = {
      file = ../../../../secrets/aider.env;
      mode = "0400";
      owner = "christoph";
    };
    environment.systemPackages = with pkgs; [
      wrapped
      iwe
      inputs.lumen.packages.${pkgs.system}.default
      fzf
      internal.project_export
      internal.open-codex
      goose-cli
      yazi
    ];

  };
}
