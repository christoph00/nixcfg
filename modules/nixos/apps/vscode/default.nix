{
  options,
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.apps.vscode;
  marketplace-extensions = with inputs.nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace; [
    visualstudioexptteam.vscodeintellicode
    johnnymorganz.stylua
    sndst00m.markdown-github-dark-pack
    codeium.codeium
  ];
in {
  options.chr.apps.vscode = with types; {
    enable = mkBoolOpt' config.chr.desktop.enable;
  };

  config = mkIf cfg.enable {
    chr.home = {
      extraOptions = {
        programs.vscode = {
          enable = true;
          package = pkgs.vscodium;
          mutableExtensionsDir = true;
          extensions = with pkgs.vscode-extensions;
            [
              kahole.magit
              redhat.vscode-yaml
              jnoortheen.nix-ide
              dhall.dhall-lang
              timonwong.shellcheck
              haskell.haskell
              justusadam.language-haskell
              # ms-python.python
              # llvm-vs-code-extensions.vscode-clangd
              stkb.rewrap
              shardulm94.trailing-spaces
              tyriar.sort-lines
              zhuangtongfa.material-theme
              esbenp.prettier-vscode
              christian-kohler.path-intellisense
              bbenoist.nix
              file-icons.file-icons
              kamadorueda.alejandra
              sumneko.lua
            ]
            ++ marketplace-extensions;
        };
      };
    };
  };
}
