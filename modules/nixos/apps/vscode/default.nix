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

  codium = pkgs.vscodium.overrideAttrs (prev: {
    version = "1.83.1.23285";
    src = pkgs.fetchurl {
      url = "https://github.com/Alex313031/codium/releases/download/1.83.1.23285/Codium_linux_x64_${version}.zip";
      sha256 = "0x3w5zw22cin83mfba6wvss6s9m8zkmy20502hscw5py156x0x2m";
    };
  });
in {
  options.chr.apps.vscode = with types; {
    enable = mkBoolOpt' config.chr.desktop.enable;
  };

  config = mkIf cfg.enable {
    chr.home = {
      extraOptions = {
        programs.vscode = {
          enable = true;
          package = codium;
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
