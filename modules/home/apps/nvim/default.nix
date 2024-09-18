{
  options,
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib)
    types
    mkIf
    ;
  inherit (lib.internal) mkBoolOpt;
  cfg = config.profiles.internal.apps.nvim;
in
{
  options.profiles.internal.apps.nvim = with types; {
    enable = mkBoolOpt true "Enable Neovim Config";
  };

  config = mkIf cfg.enable {

  };

}
