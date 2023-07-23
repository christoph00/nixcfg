{
  self,
  inputs,
  config,
  ...
}: {
  flake = {
    homeModules = {
      common = {
        home.stateVersion = "22.11";
        imports = [
          inputs.nix-colors.homeManagerModule
          # inputs.nixneovim.nixosModules.default
          ./cli
          ../modules/home-manager
        ];
      };
      desktop.imports = [
        #inputs.hyprland.homeManagerModules.default
        inputs.ironbar.homeManagerModules.default
        inputs.anyrun.homeManagerModules.default
        ./desktop
        ./applications
      ];
      monitors-laptop.imports = [
        {
          monitors = [
            {
              enabled = true;
              name = "eDP-1";
              width = 1920;
              height = 1080;
              isPrimary = true;
              refreshRate = 59;
              x = 0;
              y = 0;
              workspace = "1";
            }
          ];
        }
      ];
      monitors-desktop.imports = [
        {
          monitors = [
            {
              enabled = true;
              name = "DP-2";
              width = 3840;
              height = 2160;
              isPrimary = true;
              refreshRate = 60;
              x = 0;
              y = 0;
              scale = "1.51";
            }
            {
              enabled = false;
              name = "DP-1";
              width = 1920;
              height = 1080;
              isPrimary = false;
              refreshRate = 60;
              scale = "1";
            }
          ];
        }
      ];
      gaming.imports = [./gaming];
    };
  };
}
