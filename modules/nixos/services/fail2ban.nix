{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
{

  config = {

    services.fail2ban = {
      enable = true;
      banaction = "nftables-multiport";
      banaction-allports = "nftables-allport";
      packageFirewall = pkgs.nftables;
      maxretry = 7;
      ignoreIP = [
        "127.0.0.0/8"
        "10.0.0.0/8"
        "192.168.0.0/16"
      ];

      jails = mkMerge [
        {
          sshd = mkForce ''
            enabled = true
            port = ${concatStringsSep "," (map toString config.services.openssh.ports)}
            mode = aggressive
          '';
        }
      ];

      bantime-increment = {
        enable = true;
        rndtime = "12m";
        overalljails = true;
        multipliers = "4 8 16 32 64 128 256 512 1024 2048";
        maxtime = "192h";
      };

    };

  };

}
