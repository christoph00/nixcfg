{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.apps.wezterm;
in {
  options.chr.apps.wezterm = with types; {
    enable = mkBoolOpt false "Whether to enable Wezterm.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.wezterm];
  };
}
