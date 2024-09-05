{
  options,
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
with lib;
with lib.internal;
let
  cfg = config.internal.user;
in
{
  options.internal.user = with types; {
    name = mkOpt str "christoph" "The name to use for the user account.";
    fullName = mkOpt str "Christoph" "The full name of the user.";
    email = mkOpt str "christoph@asche.co" "The email of the user.";
    initialPassword = mkOpt str "Start01" "The initial password to use when the user is first created.";
    prompt-init = mkBoolOpt true "Whether or not to show an initial message when opening a new shell.";
    extraGroups = mkOpt (listOf str) [ ] "Groups for the user to be assigned.";
    extraOptions = mkOpt attrs { } (mdDoc "Extra options passed to `users.users.<name>`.");
  };

  config = {

    programs.zsh = {
      enable = true;
      autosuggestions.enable = true;
      histFile = "$XDG_CACHE_HOME/zsh.history";
    };

    internal.home = {
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
            syntaxHighlighting.enable = true;

            autosuggestion.enable = true;

            initExtra = ''
              # Fix an issue with tmux.
              export KEYTIMEOUT=1

              # Use vim bindings.
              set -o vi

              # Improved vim bindings.
              source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
            '';
          };
        };
      };
    };

    users.users.${cfg.name} = {
      isNormalUser = true;

      inherit (cfg) name initialPassword;

      home = "/home/${cfg.name}";
      group = "users";

      shell = pkgs.zsh;

      uid = 1000;

      openssh.authorizedKeys.keys = [
"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICRlMoMsGWPbUR9nC0XavzLmcolpF8hRbvQYALJQNMg8"
"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF0THsTwuzDioonRmt3AxoqkFp7mkIkbmc0ZLtBS58zK"
"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC33M1GqTGJYD4XKTm/tdxf2oFa+3uVeGRNx+stPF9vK"
"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHoppzmns1lt6TT2otVKHn1ErtUn5pNzJXbViaYymrLn"
"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFmHJIHJYMl/0awPcEeftLSxDKGVWmN0jhYPQ5hCINxD"
];

      extraGroups = [
        "wheel"
        "audio"
        "sound"
        "video"
        "networkmanager"
        "input"
        "tty"
      ] ++ cfg.extraGroups;
    } // cfg.extraOptions;
  };
}
