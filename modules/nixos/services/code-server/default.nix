{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.services.code-server;
in {
  options.chr.services.code-server = with types; {
    enable = mkBoolOpt false "Enable Code-Server Service.";
  };
  config = mkIf cfg.enable {
    services.openvscode-server = {
      enable = true;
      user = "christoph";
      group = "users";

      extraPackages = with pkgs; [git nixd nixfmt alejandra];
      host = "0.0.0.0";
      socketPath = "/run/openvscode/socket";
      serverDataDir = "${config.users.users.christoph.home}/.config/openvscode-server";
      withoutConnectionToken = false;
    };
    services.cloudflared.tunnels."${config.networking.hostName}" = {
      ingress = {
        "code.r505.de" = "http://127.0.0.1:${config.services.openvscode-server.port}";
      };
    };
  };
}
