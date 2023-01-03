{
  self,
  inputs,
  config,
  ...
}: {
  flake = {
    lib = {
      mkSystem = mod: system:
        inputs.nixpkgs.lib.nixosSystem rec {
          inherit system;
          # Arguments to pass to all modules.
          specialArgs = {
            inherit system inputs;
            flake = {inherit config;};
          };
          modules = [mod];
        };

      mkHomeModule = mod: user: {
        users.users.${user}.isNormalUser = true;
        home-manager.users.${user} = {
          imports =
            [
              self.homeModules.common
            ]
            ++ mod;
        };
      };
    };
  };
}
