{
  description = "nixcfg";
  nixConfig = {
    experimental-features = [
      "nix-command"
      "flakes"
      "auto-allocate-uids"
    ];
    extra-substituters = [
      "https://chr.cachix.org"
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://nyx.chaotic.cx/"
      "https://chaotic-nyx.cachix.org"
      "https://cache.garnix.io"
      "https://cosmic.cachix.org"
    ];
    extra-trusted-public-keys = [
      "chr.cachix.org-1:8Z0vNVd8hK8lVU53Y26GHDNc6gv3eFzBNwSYOcUvsgA="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nyx.chaotic.cx-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
      "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    srvos.url = "github:nix-community/srvos";
    # Use the version of nixpkgs that has been tested to work with SrvOS
    # Alternatively we also support the latest nixos release and unstable
    nixpkgs.follows = "srvos/nixpkgs";

    chaotic = {
      url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.jovian.follows = "jovian";

    };

    snowfall-lib.url = "github:snowfallorg/lib";
    snowfall-lib.inputs.nixpkgs.follows = "nixpkgs";

    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";

    agenix = {
      url = "github:yaxitech/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Snowfall Flake
    flake.url = "github:snowfallorg/flake";
    flake.inputs.nixpkgs.follows = "nixpkgs";

    # impermanence.url = "github:nix-community/impermanence";
    impermanence.url = "github:nix-community/impermanence/63f4d0443e32b0dd7189001ee1894066765d18a5";

    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Snowfall Thaw
    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser.url = "github:MarceColl/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";

    vscode-server.url = "github:nix-community/nixos-vscode-server";
    vscode-server.inputs.nixpkgs.follows = "nixpkgs";

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvimcfg = {
      url = "github:christoph00/nvimcfg";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wrapper-manager = {
      url = "github:viperML/wrapper-manager";
      # WM's nixpkgs is only used for tests, you can safely drop this if needed.
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

      overlays = with inputs; [
        flake.overlays.default
        chaotic.overlays.default
        nvimcfg.overlays.default
      ];

      systems.modules.nixos = with inputs; [
        srvos.nixosModules.common
        srvos.nixosModules.mixins-nix-experimental
        agenix.nixosModules.default
        chaotic.nixosModules.default
        {
          # manually import overlay
          chaotic.nyx.overlay.enable = false;
        }
        disko.nixosModules.disko
        nixos-cosmic.nixosModules.default
        impermanence.nixosModules.impermanence
        lanzaboote.nixosModules.lanzaboote
        # jovian.nixosModules.default
        vscode-server.nixosModules.default
        nvf.nixosModules.default
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
