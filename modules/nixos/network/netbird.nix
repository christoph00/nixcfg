{
  config,
  lib,
  flake,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (flake.lib) mkBoolOpt;
  cfg = config.network.netbird;
in
{
  options.network.netbird = {
    enable = mkBoolOpt true;
    userspace = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services.netbird = {
      enable = true;
      clients = {
        io = {
          port = 51820;
          environment.NB_SETUP_KEY_FILE = config.age.secrets."netbird-io-setup-key".path;
          emvironment.NB_WG_KERNEL_DISABLED = cfg.userspace;
          dns-resolver.address = "127.0.0.77";
          # dns-resolver.port = 5053;
        };
      };
    };
    sys.state.directories = [ "/var/lib/netbird-io" ];
    age.secrets."netbird-io-setup-key" = {
      owner = "netbird-io";
      file = ../../../secrets/netbird-io-setup.key;
    };
    systemd.services.netbird-io.postStart = ''
      /run/current-system/sw/bin/netbird-io up --dns-resolver-address 127.0.0.77
    '';

    networking.firewall.trustedInterfaces = [ "nb-io" ];
  };

}
