{
  nixpkgs,
  lib,
  inputs,
  ...
}: let
  self = inputs.self;

  mkSystem = nixpkgs.lib.nixosSystem;

  mapHosts = dir: attrs @ {system ? system, ...}:
    mapModules dir
    (hostPath: mkHost hostPath attrs);

  mkNixosSystem = {
    hostname,
    modules,
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
        modules =
          [
            "${self}/nixos/common"
            "${self}/hosts/${args.hostname}"
          ]
          ++ args.modules or [];
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
