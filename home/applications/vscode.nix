{pkgs, ...}: {
  home.persistence = {
    "/persist/home/christoph".directories = [".config/Code" ".vscode"];
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;

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
      ms-python.python
      llvm-vs-code-extensions.vscode-clangd
      stkb.rewrap
      shardulm94.trailing-spaces
    ];
    # ++ pkgs.lib.concatMap builtins.attrValues
    # (builtins.attrValues custom-extensions);
  };
}
