{
  nixpkgs,
  lib,
  inputs,
  ...
}: let
  self = inputs.self;

  mkSystem = nixpkgs.lib.nixosSystem;

  mkNixosSystem = {
    hostname,
    system,
    withSystem,
    ...
  } @ args:
    withSystem system ({
      inputs',
      self',
      ...
    }:
      mkSystem {
        inherit system;
        modules = [
          "${self}/nixos/common"
          "${self}/hosts/${args.hostname}"
        ];
        specialArgs =
          {
            inherit lib inputs self inputs' self';
            hostname = args.hostname;
          }
          // args.specialArgs or {};
      });
in {
  inherit mkSystem mkNixosSystem;
}
