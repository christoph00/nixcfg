{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.apps.obsidian;
in {
  options.chr.apps.obsidian = with types; {
    enable = mkBoolOpt config.chr.desktop.enable "Whether to enable obsidian.";
  };

  config = {
    chr.home.extraOptions = mkIf cfg.enable {
      home.packages = with pkgs; [obsidian];
    };
  };
}
