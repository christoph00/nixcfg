{
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
    programs.nix-ld.enable = true;
    chr.home = {
      extraOptions = {
        programs.vscode = {
          enable = true;
          package = pkgs.vscodium;
          mutableExtensionsDir = true;
          extensions = with pkgs.vscode-extensions;
            [
              redhat.vscode-yaml
              jnoortheen.nix-ide
              dhall.dhall-lang
              timonwong.shellcheck
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

          # userSettings = {
          #   stylua.styluaPath = lib.getExe pkgs.stylua;
          #   nix.serverPath = lib.getExe pkgs.nixd;

          #   "[css]".editor.defaultFormatter = "esbenp.prettier-vscode";
          #   "[html]".editor.defaultFormatter = "vscode.html-language-features";
          #   "[javascript]".editor.defaultFormatter = "esbenp.prettier-vscode";
          #   "[json]".editor.defaultFormatter = "esbenp.prettier-vscode";
          #   "[jsonc]".editor.defaultFormatter = "esbenp.prettier-vscode";
          #   "[lua]".editor.defaultFormatter = "johnnymorganz.stylua";
          #   "[nix]".editor.defaultFormatter = "kamadorueda.alejandra";
          # };
        };
      };
    };
  };
}
