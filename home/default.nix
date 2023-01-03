{
  self,
  inputs,
  config,
  ...
}: {
  flake = {
    homeModules = {
      common = {
        home.stateVersion = "22.11";
        imports = [
          ./tmux.nix
          ./starship.nix
          ./terminal.nix
          ./direnv.nix
        ];
      };
    };
  };
}
