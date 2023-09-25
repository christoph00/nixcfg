{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.apps.vscode;
in {
  options.chr.apps.vscode = with types; {
    enable = mkBoolOpt false "Whether or not to enable Firefox.";
  };

  config = mkIf cfg.enable {
    chr.home = {
      extraOptions = {
        programs.vscode = {
          enable = true;
        };
      };
    };
  };
}
