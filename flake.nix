{
  description = "nixos config";

  nixConfig.extra-substituters = [
    "https://cache.garnix.io"
  ];
  nixConfig.extra-trusted-public-keys = [
    "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
  ];

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    snowfall-frost = {
      url = "github:snowfallorg/frost";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    snowfall-flake = {
      url = "github:snowfallorg/flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:yaxitech/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };

    impermanence.url = "github:nix-community/impermanence";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:nixos/nixos-hardware";

    disko = {
      url = github:nix-community/disko;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-colors = {
      url = "github:misterio77/nix-colors";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    anyrun = {
      url = "github:Kirottu/anyrun";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";

    ags = {
      url = "github:Aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helix = {
      url = "github:helix-editor/helix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };

    cosmic-applets = {
      url = "github:pop-os/cosmic-applets";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cosmic-applibrary = {
      url = "github:pop-os/cosmic-applibrary";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cosmic-bg = {
      url = "github:pop-os/cosmic-bg";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cosmic-comp = {
      url = "github:pop-os/cosmic-comp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cosmic-launcher = {
      url = "github:pop-os/cosmic-launcher";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cosmic-osd = {
      url = "github:pop-os/cosmic-osd";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cosmic-panel = {
      url = "github:pop-os/cosmic-panel";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cosmic-session = {
      url = "github:pop-os/cosmic-session";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cosmic-settings = {
      url = "github:pop-os/cosmic-settings";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cosmic-settings-daemon = {
      url = "github:pop-os/cosmic-settings-daemon";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    xdg-desktop-portal-cosmic = {
      url = "github:pop-os/xdg-desktop-portal-cosmic";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs: let
    lib = inputs.snowfall-lib.mkLib {
      inherit inputs;
      src = ./.;

      snowfall = {
        meta = {
          name = "chr";
          title = "Christoph's NixOS Config";
        };

        namespace = "chr";
      };
    };
  in
    lib.mkFlake {
      channels-config = {
        allowUnfree = true;
        permittedInsecurePackages = [
          "qtwebkit-5.212.0-alpha4"
          "electron-24.8.6"
        ];
      };

      systems.modules.nixos = with inputs; [
        home-manager.nixosModules.home-manager
        agenix.nixosModules.age
      ];
    };
}
