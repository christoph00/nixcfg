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
  options.chr.apps.thunderbird = mkOpt types.bool config.chr.desktop.enable "Enable Thunderbird.";

  config = mkIf cfg.thunderbird {
    programs.thunderbird = {
      enable = true;
    };
  };
}
