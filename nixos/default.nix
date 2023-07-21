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
      home-headless-christoph = self.lib.mkHomeModule [] "christoph";

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
          inputs.disko.nixosModules.disko
          self.nixosModules.home-manager
          inputs.tsnsrv.nixosModules.default

          inputs.srvos.nixosModules.common
          inputs.srvos.nixosModules.mixins-systemd-boot
          inputs.srvos.nixosModules.mixins-terminfo

          self.nixosModules.tailscale-tls
          self.nixosModules.pia-vpn

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
        self.nixosModules.autologin-graphical-session
        inputs.srvos.nixosModules.desktop
        ./desktop.nix
        ./fonts.nix
        #./plasma.nix
        ./hyprland.nix
        #./xfce.nix
        #./gnome.nix
        #./greetd.nix
        ./printing.nix
        ./rclone-christoph.nix
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
        ./acme.nix
        self.nixosModules.headless
        inputs.srvos.nixosModules.mixins-nginx
      ];
      virtual.imports = [
        "${inputs.nixpkgs}/nixos/modules/profiles/qemu-guest.nix"
      ];
      smart-home.imports = [
        ./smart-home.nix
        ./home-assistant
      ];
      home-server.imports = [
        # ./cloudflared.nix
        ./home-server.nix
        #./immich.nix
        #./matcha.nix
        #self.nixosModules.syncthing
        #./photoview.nix
        #./photoprism.nix
      ];

      sdImage.imports = [
        "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image.nix"
        ./sd.nix
      ];

      code-server.imports = [./code-server.nix];

      media-server.imports = [./media-server.nix];

      caldav.imports = [./caldav.nix];

      nextcloud.imports = [./nextcloud.nix ./acme.nix];

      vm-win11.imports = [
        ./gpu_passthrough.nix
        ./win11.nix
      ];
      syncthing.imports = [./syncthing.nix];

      mailserver.imports = [
        ./mailserver.nix
      ];

      gamestream.imports = [
        #./acme.nix
        ./sunshine.nix
      ];

      wg-pia.imports = [./wg-pia.nix];
      gaming.imports = [./gaming.nix];

      nzb.imports = [./nzb.nix];

      feeds.imports = [./feed2imap.nix];

      reverse-proxy-server.imports = [./reverse-proxy-server.nix];
      remote-server.imports = [./remote-server.nix];
      router.imports = [./router];
      immich.imports = [./immich.nix];
      webdav-server.imports = [./webdav-server.nix];
    };
  };
}
