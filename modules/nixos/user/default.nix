{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.user;
in {
  options.chr.user = with types; {
    name = mkOpt str "christoph" "The name to use for the user account.";
    fullName = mkOpt str "christoph" "The full name of the user.";
    email = mkOpt str "christoph@asche.co" "The email of the user.";
    hashedPasswordFile =
      mkOpt str config.age.secrets.user-password.path
      "Hashed Password File";
    icon =
      mkOpt (nullOr package) defaultIcon
      "The profile picture to use for the user.";
    extraGroups = mkOpt (listOf str) [] "Groups for the user to be assigned.";
    authorizedKeys = mkOpt (listOf str) [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKBCs+VL1FAip0JZ2wWnop9lUZHcs30mibUwwrMJpfAX christoph@air13"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICRlMoMsGWPbUR9nC0XavzLmcolpF8hRbvQYALJQNMg8 christoph@tower"
    ] "Authorized Keys.";

    extraOptions =
      mkOpt attrs {}
      (mdDoc "Extra options passed to `users.users.<name>`.");
  };

  config = {

    age.secrets.user-password.file = "../../secrets/christoph-password.age";
    
    programs.zsh = {
      enable = true;
      autosuggestions.enable = true;
      histFile = "$XDG_CACHE_HOME/zsh.history";
    };

    chr.home = {
      extraOptions = {
        programs = {
          starship = {
            enable = true;
            settings = {
              character = {
                success_symbol = "[➜](bold green)";
                error_symbol = "[✗](bold red) ";
                vicmd_symbol = "[](bold blue) ";
              };
            };
          };

          zsh = {
            enable = true;
            enableCompletion = true;
            enableAutosuggestions = true;
            enableSyntaxHighlighting = true;

            plugins = [
              {
                name = "zsh-nix-shell";
                file = "nix-shell.plugin.zsh";
                src = pkgs.fetchFromGitHub {
                  owner = "chisui";
                  repo = "zsh-nix-shell";
                  rev = "v0.4.0";
                  sha256 = "037wz9fqmx0ngcwl9az55fgkipb745rymznxnssr3rx9irb6apzg";
                };
              }
            ];
          };
        };
      };
    };

    users.users.${cfg.name} =
      {
        isNormalUser = true;

        inherit (cfg) name hashedPasswordFile;

        home = "/home/${cfg.name}";
        group = "users";

        shell = pkgs.zsh;

        uid = 1000;

        extraGroups = [] ++ cfg.extraGroups;

        openssh.authorizedKeys.keys = [] ++ cfg.authorizedKeys;
      }
      // cfg.extraOptions;
  };
}
