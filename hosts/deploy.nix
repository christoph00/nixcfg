{
  self,
  inputs,
  ...
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
