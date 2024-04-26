{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.desktop.remote;
in {
  options.chr.desktop.remote = with types; {
    enable = mkBoolOpt false "Enable Remote Desktop Service.";
  };
  config = mkIf cfg.enable {
    # systemd.services.krdp = {
    #   wantedBy = ["multi-user.target"];
    #   after = ["network.target"];
    #   description = "krdp daemon";
    #   #preStart = '''';
    #   serviceConfig = {
    #     User = "krdp";
    #     Group = "krdp";
    #     PermissionsStartOnly = true;
    #     ExecStart = "${pkgs.chr.krdp}/bin/krdp ";
    #   };
    # };

    # users.users.krdp = {
    #   description = "krdp daemon user";
    #   isSystemUser = true;
    #   group = "krdp";
    # };
    # users.groups.krdp = {};

    # security.pam.services.krdp = {
    #   allowNullPassword = true;
    #   startSession = true;
    # };

    services.xrdp.enable = true;

    services.cloudflared.tunnels."${config.networking.hostName}" = {
      ingress = {
        "desk.r505.de" = "rdp://127.0.0.1:3389";
      };
    };
  };
}
