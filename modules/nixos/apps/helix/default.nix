{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.apps.helix;
in {
  options.chr.apps.vscode = with types; {
    enable = mkBoolOpt' config.chr.desktop.enable;
    defaultEditor = mkBoolOpt' true;
  };

  config = mkIf cfg.enable {
    chr.home = {
      extraOptions = {
        home.sessionVariables = mkIf cfg.defaultEditor {
          EDITOR = "hx";
        };

        programs.helix = {
          enable = true;
          settings = {
            editor = {
              line-number = "relative";
              mouse = true;
              true-color = true;
              cursorline = true;
              cursorcolumn = false;
              gutters = ["diff" "diagnostics" "line-numbers" "spacer" "spacer"];

              cursor-shape = {
                insert = "bar";
                normal = "block";
                select = "underline";
              };

              file-picker.hidden = false;

              statusline = {
                left = ["mode" "spinner" "file-modification-indicator" "version-control"];
                center = ["file-name" "total-line-numbers"];
                right = ["diagnostics" "selections" "position" "file-encoding" "file-line-ending" "file-type"];
                separator = "|";
                mode.normal = "NORMAL";
                mode.insert = "INSERT";
                mode.select = "SELECT";
              };

              lsp = {
                enable = true;
                display-messages = true;
                display-inlay-hints = true;
              };

              indent-guides = {
                render = false;
                skip-level = 1;
              };
            };
          };
          languages = {
            language = [
              {
                name = "nix";
                indent.tab-width = 2;
                indent.unit = "  ";
                language-server = {
                  command = "${pkgs.nixd}/bin/nixd";
                  args = [];
                };
              }
            ];
          };
        };
      };
    };
  };
}
