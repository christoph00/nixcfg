{
  lib,
  config,
  flake,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (flake.lib) mkBoolOpt mkStrOpt;

  cfg = config.svc.code-tunnel;
in {
  options.svc.code-tunnel = {
    enable = mkBoolOpt false;
    user = mkStrOpt "christoph";
  };
  config = mkIf cfg.enable {
    systemd.services.code-tunnel = {
      description = "VSCode Tunnel Server";
      wantedBy = ["default.target"];
      after = [
        "network.target"
      ];
      path = [
        pkgs.nodejs
        pkgs.python3
        pkgs.uv
        pkgs.wget
        config.nix.package
        pkgs.git
        pkgs.vscode
        pkgs.bashInteractive
        pkgs.nixd
      ];
      script = "${pkgs.vscode}/lib/vscode/bin/code-tunnel --cli-data-dir $HOME/.vscode/cli tunnel service internal-run";
      serviceConfig = {
        User = "${cfg.user}";
        RestartSec = 30;
        WorkingDirectory = "/home/${cfg.user}";
      };
    };
  };
}
