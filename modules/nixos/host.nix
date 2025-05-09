{
  inputs,
  flake,
  options,
  ...
}:
let
  inherit (flake.lib) mkOpt mkBoolOpt;

in
{
  imports = [
    inputs.nixos-facter-modules.nixosModules.facter
    flake.modules.nixos.system
    flake.modules.nixos.secrets
    flake.modules.nixos.minimal
    flake.modules.nixos.users
    flake.modules.nixos.network
    flake.modules.nixos.shell
    flake.modules.nixos.sevices
  ];

  options.host = {
    bootstrap = mkBoolOpt false;
  };

}
