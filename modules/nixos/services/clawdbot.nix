{
  lib,
  config,
  flake,
  pkgs,
  perSystem,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (flake.lib) mkBoolOpt mkStrOpt;

  cfg = config.svc.clawdbot;
in
{
  options.svc.clawdbot = {
    enable = mkBoolOpt false;
    user = mkStrOpt "christoph";
  };
  config = mkIf cfg.enable {
    programs.nix-ld.enable = true;
    systemd.services.clawdbot = {
      description = "clawdbot gateway";
      wantedBy = [ "default.target" ];
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
        pkgs.bashInteractive
        pkgs.signal-cli
      ];
      script = "${pkgs.nodejs}/bin/npx run openclaw@latest gateway";
      serviceConfig = {
        User = "${cfg.user}";
        RestartSec = 30;
        WorkingDirectory = "/home/${cfg.user}";
      };
    };
  };
}
