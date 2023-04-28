{
  self,
  inputs,
  ...
<<<<<<< HEAD
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

||||||| parent of b34a42b ()
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

=======
}: {
  flake.deploy.nodes = (
    builtins.mapAttrs
    (
      hostname: attr: {
        inherit hostname;
        fastConnection = true;
        profiles = {
          system = {
            sshUser = "christoph";
            user = "root";
            path =
              inputs.deploy-rs.lib."${attr.config.nixpkgs.system}".activate.nixos
              self.nixosConfigurations."${hostname}";
          };
        };
      }
    )
    self.nixosConfigurations
  );
>>>>>>> b34a42b ()
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
