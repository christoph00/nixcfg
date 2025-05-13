{
  lib,
  flake,
  pkgs,
  config,
  options,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (flake.lib) mkBoolOpt;
  cfg = config.sys;
in
{
  options.sys.console = mkBoolOpt true;
  config = mkIf cfg.console {
    console = {
      enable = true;
      earlySetup = true;
      keyMap = "de";
      font = "${pkgs.terminus_font}/share/consolefonts/ter-d18n.psf.gz";
    };
  };
}
