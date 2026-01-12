{
  config,
  lib,
  inputs,
  flake,
  ...
}: let
  inherit (lib) mkIf;
  inherit (flake.lib) enabled;
in {
  imports = [
    inputs.nvf.nixosModules.default
    ./options.nix
    ./mini.nix
    ./languages.nix
    ./lsp.nix
    ./assistant.nix
    ./keymaps.nix
    #    ./mcphub.nix
    #    ./repl.nix
    #    ./mail.nix
    #    ./notes.nix
  ];

  config = mkIf config.programs.nvf.enable {
    programs.nvf = {
      settings = {
        vim = {
          # additionalRuntimePaths = [ ./runtime ];
          extraLuaFiles = [
            # ./autocmds.lua
          ];
          # globals.mapleader = " ";
          enableLuaLoader = true;

          syntaxHighlighting = true;
          fzf-lua.enable = true;
          clipboard = {
            enable = true;
            registers = "unnamed,unnamedplus";
          };

          ui = {
            fastaction.enable = true;
          };

          utility = {
            snacks-nvim.enable = true;
            ccc.enable = false;
          };

          autocomplete.blink-cmp = {
            enable = true;
            friendly-snippets.enable = true;
            setupOpts = {
              signature.enabled = true;
              cmdline = {
                keymap.preset = "cmdline";
                completion.menu.auto_show = true;
              };
            };
          };

          diagnostics = {
            enable = true;
            config = {
              virtual_text.enable = true;
              severity_sort = true;
              signs.text = lib.generators.mkLuaInline ''
                {
                  [vim.diagnostic.severity.ERROR] = " ",
                  [vim.diagnostic.severity.WARN] = " ",
                  [vim.diagnostic.severity.INFO] = " ",
                  [vim.diagnostic.severity.HINT] = " ",
                }
              '';
            };
          };

          binds.whichKey = {
            enable = true;
            setupOpts.preset = "helix";
          };

          theme = {
            enable = true;
            name = "mini-base16";
            transparent = true;
            base16-colors = {
              base00 = "#ffffff"; # Hintergrund
              base01 = "#f8f8f8"; # heller Hintergrund
              base02 = "#e0e0e0"; # Auswahl
              base03 = "#7a7a7a"; # Kommentar (neu, dunkler)
              base04 = "#505050"; # hellere Kommentare / Sekundärtext
              base05 = "#000000"; # Standard-Text
              base06 = "#202020"; # dunkler Text
              base07 = "#101010"; # sehr dunkler Text
              base08 = "#a60000"; # Rot (Fehler)
              base09 = "#b65c00"; # Orange
              base0A = "#a45bad"; # Magenta
              base0B = "#006800"; # Grün
              base0C = "#205ea6"; # Cyan/Blau
              base0D = "#1f1f1f"; # Dunkelblau
              base0E = "#721045"; # Violett
              base0F = "#8f0075"; # Pink
            };
          };

          luaConfigPost = ''
            if vim.g.neovide then
              vim.keymap.set('n', '<D-s>', ':w<CR>') -- Save
              vim.keymap.set('v', '<D-c>', '"+y') -- Copy
              vim.keymap.set('n', '<D-v>', '"+P') -- Paste normal mode
              vim.keymap.set('v', '<D-v>', '"+P') -- Paste visual mode
              vim.keymap.set('c', '<D-v>', '<C-R>+') -- Paste command mode
              vim.keymap.set('i', '<D-v>', '<ESC>l"+Pli') -- Paste insert mode
            end
            vim.filetype.add({
             pattern = {
              ['.*%.blade%.php'] = 'php',
             }
            });
          '';
        };
      };
    };
  };
}
