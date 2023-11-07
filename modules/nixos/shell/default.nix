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

      programs.fish.enable = true; # for completions
      programs.nushell = {
        enable = true;
        extraConfig = ''
          $env.config = {
            show_banner: false
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
    };
  };
}
