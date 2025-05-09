{ inputs, config, ... }:
{
  imports = [ inputs.agenix.nixosModules.default ];
  config = {

    age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  };
}
