{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.apps.vscode;
in {
  options.chr.apps.vscode = with types; {
    enable = mkBoolOpt' false;
  };

  config = mkIf cfg.enable {
    chr.home = {
      extraOptions = {
        programs.vscode = {
          enable = true;
          mutableExtensionsDir = true;
          extensions = with pkgs.vscode-extensions; [
            kahole.magit
            redhat.vscode-yaml
            jnoortheen.nix-ide
            dhall.dhall-lang
            timonwong.shellcheck
            bungcip.better-toml
            haskell.haskell
            justusadam.language-haskell
            # ms-python.python
            # llvm-vs-code-extensions.vscode-clangd
            stkb.rewrap
            shardulm94.trailing-spaces
            tyriar.sort-lines
            zhuangtongfa.material-theme
          ];
        };
      };
    };
  };
}
