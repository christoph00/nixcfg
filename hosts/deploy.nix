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
      profiles.system.path = (activateFor "x86_64-linux") self.nixosConfigurations.alpha;
    };
  };

  perSystem = {
    self',
    inputs',
    system,
    lib,
    config,
    pkgs,
    ...
  }: {
    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) inputs.deploy-rs.lib;
    apps = {
      default = {
        type = "app";
        program = "${inputs'.deploy-rs.packages.deploy-rs}/bin/deploy";
      };
    };
  };
}
