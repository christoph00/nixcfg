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
  cfg = config.chr.apps.helix;
in {
  options.chr.apps.helix = with types; {
    enable = mkBoolOpt' config.chr.desktop.enable;
    defaultEditor = mkBoolOpt' true;
  };

  config = mkIf cfg.enable {
    chr.home = {
      extraOptions = {
        home.sessionVariables = mkIf cfg.defaultEditor {EDITOR = "hx";};

        home.packages = [pkgs.templ];

        programs.helix = {
          enable = true;
          package = inputs.helix.outputs.packages.${pkgs.stdenv.hostPlatform.system}.helix;
          settings = {
            theme = "fleet_dark";
            editor = {
              line-number = "relative";
              mouse = true;
              true-color = true;
              cursorline = true;
              cursorcolumn = false;
              gutters = [
                "diff"
                "diagnostics"
                "line-numbers"
                "spacer"
                "spacer"
              ];

              cursor-shape = {
                insert = "bar";
                normal = "block";
                select = "underline";
              };

              file-picker.hidden = false;

              statusline = {
                left = [
                  "mode"
                  "spinner"
                  "file-modification-indicator"
                  "version-control"
                ];
                center = [
                  "file-name"
                  "total-line-numbers"
                ];
                right = [
                  "diagnostics"
                  "selections"
                  "position"
                  "file-encoding"
                  "file-line-ending"
                  "file-type"
                ];
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
            keys = {
              normal = {
                "C-n" = [
                  "extend_line"
                  ":insert-output echo 'FILL_THIS'"
                  "extend_line_below"
                  ":pipe ${pkgs.chr.tgpt}/bin/tgpt --code 'Using this comment, fill the line having the comment FILL_THIS.'"
                ];
              };
            };
          };
          languages.language-server = {
            nixd.command = "${pkgs.nixd}/bin/nixd";
            deno = {
              command = "${pkgs.deno}/bin/deno";
              args = ["lsp"];
              config = {
                enable = true;
                unstable = true;
                lint = true;
              };
            };

            tailwindcss = {
              command = "${
                pkgs.nodePackages_latest."@tailwindcss/language-server"
              }/bin/tailwindcss-language-server";
              language-id = "tailwindcss";
              args = ["--stdio"];
              config = {};
            };
          };
          languages.language = [
            {
              name = "nix";
              language-servers = ["nixd"];
              auto-format = true;
              formatter = {
                command = "${pkgs.alejandra}/bin/alejandra";
                args = ["-"];
              };
            }
          ];
        };
      };
    };
  };
}
