{
  self,
  inputs,
  ...
}: let
  activateFor = system: inputs.deploy-rs.lib.${system}.activate.nixos;
in {
  flake.deploy.nodes = {
    futro = {
      hostname = "10.10.10.66";
      sshUser = "christoph";
      profiles.system.path = (activateFor "x86_64-linux") self.nixosConfigurations.futro;
    };
  };

  flake.checks =
    builtins.mapAttrs
    (system: deployLib: deployLib.deployChecks self.deploy)
    inputs.deploy-rs.lib;

  perSystem = {
    self',
    inputs',
    system,
    lib,
    config,
    pkgs,
    ...
  }: {
    apps = {
      default = {
        type = "app";
        program = "${inputs'.deploy-rs.packages.deploy-rs}/bin/deploy";
      };
    };
  };
}
