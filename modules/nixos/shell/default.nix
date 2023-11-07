{
  inputs,
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.shell;
in {
  options.chr.apps.cli = with types; {
    enable = mkBoolOpt' true;
  };

  config = mkIf cfg.enable {
    chr.home.extraOptions = {
      programs.nushell = {
        enable = true;
      };

      home.packages = [pkgs.nu_scripts];
    };
  };
}
