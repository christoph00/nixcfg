{
  lib,
  config,
  pkgs,
  osConfig ? {},
  ...
}: let
  inherit (lib) types mkIf mkDefault mkMerge;
  inherit (lib.chr) mkOpt;

  cfg = config.chr.apps;
in {
  options.chr.apps.enable = mkOpt types.bool config.chr.desktop.enable "Enable Apps.";

  config = mkIf cfg.thunderbird {
    home.packages = with pkgs; [
      krita
      inkscape
      obsidian
      logseq
    ];
  };
}
