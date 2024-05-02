{
  inputs,
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr;
let
  cfg = config.chr.shell;
in
{
  options.chr.shell = with types; {
    enable = mkBoolOpt' true;
  };

  config = mkIf cfg.enable {
    users.users.christoph.shell = pkgs.bash;
    chr.home.extraOptions = {
      programs.direnv.enableBashIntegration = true;

      programs.starship = {
        enable = true;
      };
      programs.starship.enableBashIntegration = true;
    };
  };
}
