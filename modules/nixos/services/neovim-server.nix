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
  };
  config = mkIf config.svc.neovim-server.enable {
    systemd.services.neovim-server = {
      description = "Neovim Server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Environment = "PATH=/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin"; # TODO: fixed bins ?
        Type = "simple";
        User = config.svc.neovim-server.user;
        ExecStart = "${config.programs.nvf.finalPackage}/bin/nvim --listen 0.0.0.0:10066 --headless";
        Restart = "always";
        RestartSec = 5;
        WorkingDirectory = "/home/${config.svc.neovim-server.user}/Code";
      };
    };
  };
}
