{
  config,
  lib,
  pkgs,
  flake,
  perSystem,
  ...
}: let
  inherit (lib) mkIf;
  inherit (flake.lib) mkBoolOpt mkSecret enabled;
  cfg = config.shell.office;
in {
  options.shell.office = {
    enable = mkBoolOpt config.host.graphical;
  };

  config = mkIf cfg.enable {
    programs.yazi = {
      enable = true;
      plugins = with pkgs; {
    git = yaziPlugins.git;
    diff = yaziPlugins.diff;
    lsar = yaziPlugins.lsar;
    sudo = yaziPlugins.sudo;
    piper = yaziPlugins.piper;
    chmod = yaziPlugins.chmod;
    mount = yaziPlugins.mount;
    yatline = yaziPlugins.yatline;
    full-border = yaziPlugins.full-border;
    smart-filter = yaziPlugins.smart-filter;
  };


    };
    home.packages = with pkgs; [
       aerc
       meli
       nchat
       csvlens
    ];
  };
}
