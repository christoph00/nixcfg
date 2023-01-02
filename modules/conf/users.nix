{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.conf.users;
in {
  options = with lib; {
    conf.users = {
      enable = mkEnableOption "users";

      user = mkOption {
        type = types.str;
        default = "christoph";
      };

      name = mkOption {
        type = types.str;
        default = "Christoph";
      };

      group = mkOption {
        type = types.str;
        default = "users";
      };

      home-manager = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.user} = {
      description = cfg.name;
      isNormalUser = true;
      home = "/home/${cfg.user}";
      createHome = true;
      group = cfg.group;
      shell = pkgs.fish;
      extraGroups = [
        "wheel"
        "video"
        "audio"
        "input"
        "dbus"
        "adbusers"
        "lp"
        "scanner"
        "sound"
      ];

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ8DAhxI8pTuC6L4UucApXzuJaDNa+qqqn+H++h5f7QH christoph@air13win"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM7WLYIiZhnutMwzJx49O4i5QV2S4LndBeKeFJ914Zat christoph@air13"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII1mNuDc7hH54fzRYz8ybmO4v0dCdECuGOJN++4TfbuR christoph@WinTower"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICRlMoMsGWPbUR9nC0XavzLmcolpF8hRbvQYALJQNMg8 christoph@nixTower"
      ];
      password = "hallo009";
    };

    home-manager = lib.mkIf (cfg.home-manager) {
      useUserPackages = true;
      useGlobalPkgs = true;
      backupFileExtension = "bak";

      users.${config.conf.users.user} = {
        imports = [
          # inputs.nix-colors.homeManagerModule
          ../home-manager
          inputs.impermanence.nixosModules.home-manager.impermanence
        ];

        nix = {
          settings = {
            experimental-features = ["nix-command" "flakes" "repl-flake"];
            warn-dirty = false;
          };
        };

        systemd.user.startServices = "sd-switch";

        programs = {
          home-manager.enable = true;
          git.enable = true;
        };

        home = {
          username = config.conf.users.user;
          homeDirectory = lib.mkDefault "/home/${config.conf.users.user}";
          stateVersion = lib.mkDefault "22.11";

          persistence = {
            "/persist/home/${config.conf.users.user}" = {
              directories = [
                "Dokumente"
                "Downloads"
                "Bilder"
                "Videos"
                "Code"
              ];
              allowOther = true;
            };
          };
        };
      };
    };
  };
}
