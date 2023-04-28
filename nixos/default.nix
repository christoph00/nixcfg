{
  self,
  inputs,
  config,
  modulesPath,
  ...
}: {
  flake = {
    nixosModules = {
      home-desktop-christoph = self.lib.mkHomeModule [self.homeModules.desktop self.homeModules.monitors-desktop self.homeModules.gaming] "christoph";
      home-laptop-christoph = self.lib.mkHomeModule [self.homeModules.desktop self.homeModules.monitors-laptop] "christoph";
      home-desktop-nina = self.lib.mkHomeModule [self.homeModules.desktop self.homeModules.monitors-desktop self.homeModules.gaming] "nina";
      home-laptop-nina = self.lib.mkHomeModule [self.homeModules.desktop self.homeModules.monitors-laptop] "nina";

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

          self.nixosModules.tailscale-tls

          ./common.nix
          ./tailscale.nix
          ./agent.nix
        ];
        nixpkgs.overlays = builtins.attrValues self.overlays;
        nixpkgs.config.allowUnfree = true;
      };
      desktop.imports = [
        inputs.home-manager.nixosModule
        #inputs.hyprland.nixosModules.default
        self.nixosModules.default
        self.nixosModules.home-manager
        self.nixosModules.autologin-graphical-session
        inputs.srvos.nixosModules.desktop
        ./desktop.nix
        ./fonts.nix
        #./plasma.nix
        ./hyprland.nix
        ./xfce.nix
        #./gnome.nix
        #./greetd.nix
        ./printing.nix
        #./rclone-christoph.nix
        #./sway.nix
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
        ./acme.nix
        # ./cloudflared.nix
        ./home-server.nix
        ./matcha.nix
        #./adguardhome.nix
        #inputs.srvos.nixosModules.mixins-nginx
        self.nixosModules.sftpgo
        #self.nixosModules.syncthing
      ];

      sdImage.imports = [
        "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image.nix"
        ./sd.nix
      ];

      code-server.imports = [./code-server.nix];

      caldav.imports = [./caldav.nix];

      vm-win11.imports = [
        ./gpu_passthrough.nix
        ./win11.nix
      ];
      syncthing.imports = [./syncthing.nix];

      mailserver.imports = [
        self.nixosModules.stalwart
        ./mailserver.nix
      ];

      gamestream.imports = [
        #./acme.nix
        ./sunshine.nix
      ];
      gaming.imports = [./gaming.nix];

      reverse-proxy-server.imports = [./reverse-proxy-server.nix];
      remote-server.imports = [./remote-server.nix];
      router.imports = [./router];
    };
  };
}
