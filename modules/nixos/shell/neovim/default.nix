{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.internal;
let
  cfg = config.internal.shell.neovim;
in
{
  options.internal.shell.neovim = with types; {
    enable = mkBoolOpt config.internal.isDesktop "Whether or not to configure neovim config.";
  };

  config = mkIf cfg.enable {
    programs.nvf = {
      enable = true;

    };
  };
}
