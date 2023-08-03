{
  inputs',
  lib,
  ...
}: {
  programs.vscode = {
    enable = true;
    package = inputs'.unfree.legacyPackages.vscode;

    mutableExtensionsDir = true;
    extensions = with inputs'.unfree.legacyPackages.vscode-extensions; [
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
      kamikillerto.vscode-colorize
    ];
    # ++ pkgs.lib.concatMap builtins.attrValues
    # (builtins.attrValues custom-extensions);
  };
}
