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
in
{
  options.internal.shell.devtools = with types; {
    enable = mkBoolOpt config.internal.isGraphical "Whether or not to configure neovim config.";
  };

  config = mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      iwe
      inputs.lumen.packages.${pkgs.system}.default
      fzf
      internal.project_export
      internal.open-codex
      # aider-chat
      goose-cli
      yazi
      inputs.aider-nix.packages.${system}.aider-chat.override
      {
        withBrowser = true;
        withHelp = true;
        withAllFeatures = true;
        withPlaywright = true;
        # Other options: withPlaywright, withAllFeatures
      }
    ];

  };
}
