{
  inputs,
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.shell;
in {
  options.chr.shell = with types; {
    enable = mkBoolOpt' true;
  };

  config = mkIf cfg.enable {
    users.users.christoph.shell = pkgs.nushell;
    chr.home.extraOptions = {
      programs.direnv.enableNushellIntegration = true;

      programs.starship = {
        enable = true;
      };

      programs.fish.enable = true; # for completions
      programs.nushell = {
        enable = true;
        environmentVariables = {
          PROMPT_COMMAND = "{ def create_left_prompt [] { starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)' } }";
        };
        extraConfig = ''
          $env.config = {
            show_banner: false
            keybindings: [
            {
              name: completion_menu
              modifier: none
              keycode: tab
              mode: [emacs, vi_normal, vi_insert]
              event: {
                until: [
                  { send: menu name: completion_menu }
                  { send: menunext }
                ]
              }
            }]
            }

            # https://www.nushell.sh/cookbook/external_completers.html#fish-completer
            let fish_completer = {|spans|
               ${lib.getExe pkgs.fish} --command $'complete "--do-complete=($spans | str join " ")"'
               | $"value(char tab)description(char newline)" + $in
               | from tsv --flexible --no-infer
              }

            $env.config.completions = {
              external: {
                enable: true
                completer: $fish_completer
              }
            }
        '';
      };

      home.packages = [pkgs.nu_scripts];
      programs.starship.enableNushellIntegration = true;

      programs.helix.settings = {
        editor.shell = ["nu" "-c"];
        keys.normal."C-z" = "no_op"; # nushell doesn't have suspend
      };
    };
  };
}
