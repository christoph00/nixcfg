{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.chr;
let
  cfg = config.chr.system.ssh;
in
{
  options.chr.system.ssh = with types; {
    enable = mkBoolOpt true "Whether or not to enable ssh server.";
    hostKeyDir = mkOpt' str "/etc/ssh";
  };

  config = mkIf cfg.enable {
    services.sshguard = {
      enable = true;
      whitelist = [
        "192.168.2.0/24"
        "100.77.0.0/16"
      ];
    };
    services.openssh = {
      enable = true;
      openFirewall = true;
      startWhenNeeded = true;
      settings = {
        PermitRootLogin = lib.mkForce "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = lib.mkDefault false;
        UseDns = false;
        X11Forwarding = false;
        KexAlgorithms = [
          "curve25519-sha256"
          "curve25519-sha256@libssh.org"
          "diffie-hellman-group16-sha512"
          "diffie-hellman-group18-sha512"
          "sntrup761x25519-sha512@openssh.com"
        ];
      };

      hostKeys = [
        {
          bits = 4096;
          path = "${cfg.hostKeyDir}/ssh_host_rsa_key";
          type = "rsa";
        }
        {
          path = "${cfg.hostKeyDir}/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
    };
  };
}
