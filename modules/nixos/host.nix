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
    inputs.srvos.nixosModules.common
    inputs.lix-module.nixosModules.default
    flake.modules.nixos.system
    flake.modules.nixos.secrets
    flake.modules.nixos.minimal
    flake.modules.nixos.users
    flake.modules.nixos.network
    flake.modules.nixos.shell
    flake.modules.nixos.services
  ];

  options.host = {
    bootstrap = mkBoolOpt false;
    graphical = mkBoolOpt false;
    gaming = mkBoolOpt false;
    vm = mkBoolOpt false;
    server = mkBoolOpt false;
    container = mkBoolOpt false;
  };

}
