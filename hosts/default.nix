{
  self,
  inputs,
  ...
}: let
  inherit (inputs.nixpkgs) lib;
  inherit (inputs) nixpkgs;

  nixosSystem = args:
    (lib.makeOverridable lib.nixosSystem)
    (lib.recursiveUpdate args {
      modules =
        args.modules
        ++ [
          {
            config.nixpkgs.pkgs = lib.mkDefault args.pkgs;
            config.nixpkgs.localSystem = lib.mkDefault args.pkgs.stdenv.hostPlatform;
          }
        ];
    });

  defaultModules = [
    # make flake inputs accessiable in NixOS
    {
      _module.args.self = self;
      _module.args.inputs = self.inputs;
    }
    ({pkgs, ...}: {
      nix.nixPath = [
        "nixpkgs=${pkgs.path}"
        "home-manager=${inputs.home-manager}"
        "nur=${inputs.nur}"
      ];

      nix.extraOptions = ''
        flake-registry = ${inputs.flake-registry}/flake-registry.json
      '';
      documentation.info.enable = false;
      services.envfs.enable = true;

      imports = [
        inputs.nur.nixosModules.nur
      ];
    })
  ];
in {
  flake.nixosConfigurations = {
    air13 = nixosSystem {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules =
        defaultModules
        ++ [
          inputs.home-manager.nixosModules.home-manager
          #./air13.nix
        ];
    };
  };
}
