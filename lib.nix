{
  self,
  inputs,
  config,
  pkgs,
  lib,
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
      mkCSS = file: let
        fileName = lib.removeSuffix ".scss" (baseNameOf file);
        compiledStyles =
          pkgs.runCommand "compileScssFile"
          {buildInputs = [pkgs.sass];} ''
            mkdir "$out"
            scss --sourcemap=none \
                 --no-cache \
                 --style compressed \
                 --default-encoding utf-8 \
                 "${file}" \
                 >>"$out/${fileName}.css"
          '';
      in "${compiledStyles}/${fileName}.css";
    };
  };
}
