{
  lib,
  config,
  ...
}:

with builtins;
with lib;

let
  cfg = config.sys;
in
{

  config = {
    services.openssh = {
      enable = true;
      hostKeys = mkIf config.sys.state.enable [
        {
          path = "${cfg.state.stateDir}/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
        {
          bits = 4096;
          path = "${cfg.state.stateDir}/etc/ssh/ssh_host_rsa_key";
          type = "rsa";
        }
      ];
    };

  };
}
