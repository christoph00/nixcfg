{
  description = "nixcfg";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    chaotic.url = "https://flakehub.com/f/chaotic-cx/nyx/*.tar.gz";

    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    snowfall-lib.url = "github:snowfallorg/lib?ref=v3.0.3";
    snowfall-lib.inputs.nixpkgs.follows = "nixpkgs";

    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";

    agenix = {
      url = "github:yaxitech/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Snowfall Flake
    flake.url = "github:snowfallorg/flake?ref=v1.4.1";
    flake.inputs.nixpkgs.follows = "unstable";

    impermanence.url = "github:nix-community/impermanence";

    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Snowfall Thaw
    thaw.url = "github:snowfallorg/thaw?ref=v1.0.7";
    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    let
      lib = inputs.snowfall-lib.mkLib {
        inherit inputs;
        src = ./.;
      };
    in
    lib.mkFlake {
      channels-config = {
        allowUnfree = true;
        permittedInsecurePackages = [
          "electron-25.9.0"
          "electron-27.3.11"
        ];
      };

      overlays = with inputs; [ flake.overlays.default ];

      systems.modules.nixos = with inputs; [
        agenix.nixosModules.default
        chaotic.nixosModules.default
        disko.nixosModules.disko
        nixos-cosmic.nixosModules.default
        impermanence.nixosModules.impermanence
        nix-flatpak.nixosModules.nix-flatpak
        lanzaboote.nixosModules.lanzaboote
        home-manager.nixosModules.home-manager
      ];

      deploy = lib.mkDeploy { inherit (inputs) self; };

      checks = builtins.mapAttrs (
        system: deploy-lib: deploy-lib.deployChecks inputs.self.deploy
      ) inputs.deploy-rs.lib;

      outputs-builder = channels: { formatter = channels.nixpkgs.nixfmt-rfc-style; };

      alias = {
        shells.default = "devel";
      };
    }
    // {
      self = inputs.self;
    };

}
