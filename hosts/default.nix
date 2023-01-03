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

      documentation.info.enable = false;
      services.envfs.enable = true;
      system.stateVersion = "22.11";
      nixpkgs.config.allowUnfree = true;
      nixpkgs.overlays = builtins.attrValues self.overlays;

      imports = [
        inputs.nur.nixosModules.nur
        inputs.home-manager.nixosModules.home-manager
        inputs.base16.nixosModule
        inputs.agenix.nixosModules.age
        inputs.vscode-server.nixosModule
        inputs.hyprland.nixosModules.default
        inputs.impermanence.nixosModules.impermanence

        self.nixosModules.conf
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
          ./air13.nix
        ];
    };
  };
}
