{
  pkgs,
  config,
  flake,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (flake.lib) mkBoolOpt mkStrOpt;
in
{
  options = {
    svc.neovim-server = {
      enable = mkBoolOpt false;
      user = mkStrOpt "christoph";
    };
    config = mkIf config.svc.neovim-server.enable {
      systemd.services.neovim-server = {
        description = "Neovim Server";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        serviceConfig = {
          Type = "simple";
          User = config.svc.neovim-server.user;
          ExecStart = "${config.programs.nvf.vim.build.finalPackage}/bin/nvim --listen :10066 --headless";
          Restart = "always";
          RestartSec = 5;
          WorkingDirectory = "/home/${config.svc.neovim-server.user}/Code";
        };
      };
    };
  };
}
