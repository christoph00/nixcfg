{
  self,
  inputs,
  config,
  modulesPath,
  ...
}: {
  flake = {
    nixosModules = {
      home-desktop-christoph = self.lib.mkHomeModule [self.homeModules.desktop] "christoph";
      home-laptop-christoph = self.lib.mkHomeModule [self.homeModules.desktop self.homeModules.gaming] "christoph";

      home-manager.imports = [
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "bak";
          home-manager.extraSpecialArgs = {
            inherit inputs;
            system = "x86_64-linux";
            flake = {inherit config;};
          };
        }
      ];
      default = {
        imports = [
          "${inputs.nixpkgs}/nixos/modules/installer/scan/not-detected.nix"
          inputs.agenix.nixosModules.age
          inputs.vscode-server.nixosModule
          inputs.impermanence.nixosModules.impermanence

          inputs.srvos.nixosModules.common
          inputs.srvos.nixosModules.mixins-systemd-boot
          inputs.srvos.nixosModules.mixins-terminfo

          inputs.nix-index-database.nixosModules.nix-index

          ./common.nix
          ./tailscale.nix
        ];
        nixpkgs.overlays = builtins.attrValues self.overlays;
        nixpkgs.config.allowUnfree = true;
      };
      desktop.imports = [
        inputs.home-manager.nixosModule
        inputs.hyprland.nixosModules.default
        self.nixosModules.default
        self.nixosModules.home-manager
        inputs.srvos.nixosModules.desktop
        ./desktop.nix
        ./fonts.nix
        #./plasma.nix
        ./greetd.nix
        ./printing.nix
      ];
      laptop.imports = [
        self.nixosModules.desktop
        ./laptop.nix
      ];
      headless.imports = [
        self.nixosModules.default
        inputs.srvos.nixosModules.server
      ];
      server.imports = [
        self.nixosModules.headless
      ];
      virtual.imports = [
        "${inputs.nixpkgs}/nixos/modules/profiles/qemu-guest.nix"
      ];
      smart-home.imports = [
        ./smart-home.nix
        ./home-assistant
      ];
      home-server.imports = [
        ./cloudflared.nix
        ./home-server.nix
        inputs.srvos.nixosModules.mixins-nginx
        self.nixosModules.sftpgo
        self.nixosModules.syncthing
      ];

      code-server.imports = [./code-server.nix];

      vm-win11.imports = [
        ./gpu_passthrough.nix
        ./win11.nix
      ];
      syncthing.imports = [./syncthing.nix];
    };
  };
}
