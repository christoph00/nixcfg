{
  description = "NIX CONFIG";
  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:numtide/nixpkgs-unfree";
    nixpkgs.inputs.nixpkgs.follows = "nixpkgs-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    hardware.url = "github:NixOS/nixos-hardware";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs-unstable";
    utils = {
      url = "github:numtide/flake-utils";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    srvos.url = "github:numtide/srvos";
    srvos.inputs.nixpkgs.follows = "nixpkgs-unstable";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs-unstable";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    impermanence.url = "github:nix-community/impermanence";

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs-unstable";

    nix-init.url = "github:nix-community/nix-init";
    nix-init.inputs.nixpkgs.follows = "nixpkgs-unstable";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.flake-utils.follows = "utils";
    };

    deploy-rs = {
      # Temporarily use workaround from https://github.com/serokell/deploy-rs/pull/203
      type = "github";
      owner = "serokell";
      repo = "deploy-rs";
      ref = "rvem/%23202-add-workaround-for-derivations-store-paths-interpolation";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.utils.follows = "utils";
    };

    # helix = {
    #   url = "github:helix-editor/helix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    #   inputs.rust-overlay.follows = "rust-overlay";
    # };
    nix-colors.url = "github:misterio77/nix-colors";

    hyprland = {
      url = "github:hyprwm/hyprland/v0.24.1";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    # hyprwm-contrib = {
    #   url = "github:hyprwm/contrib";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # xdg-portal-hyprland = {
    #   url = "github:hyprwm/xdg-desktop-portal-hyprland";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    ironbar = {
      url = "github:JakeStanger/ironbar";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.rust-overlay.follows = "rust-overlay";
    };

    vscode-server = {
      url = "github:msteen/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    # nixneovim.url = "github:nixneovim/nixneovim";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux"];
      imports = [
        ./lib.nix
        ./modules
        ./nixos
        ./home
        ./hosts
        ./hosts/deploy.nix
        ./devshells.nix
      ];

      perSystem = {
        pkgs,
        config,
        self',
        ...
      }: {
        # _module.args.pkgs = import self.inputs.nixpkgs {
        #   inherit system;
        #   overlays = [self.overlays.default];
        #   config.allowUnfree = true;
        # };
        formatter = pkgs.alejandra;

        # packages = import ./pkgs {
        #   inherit pkgs;
        # };
      };
      flake.overlays = {
        default = final: prev: import ./pkgs {pkgs = final;};
      };
    };
}
