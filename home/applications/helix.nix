{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  helixUnstable = inputs.helix.outputs.packages.${pkgs.system}.helix;
  inherit (config) colorscheme;
in {
  programs.helix = {
    enable = true;
    package = helixUnstable;
    languages = [
      {
        name = "bash";
        language-server = {
          command = "${pkgs.nodePackages.bash-language-server}/bin/bash-language-server";
          args = ["start"];
        };
        auto-format = true;
      }
      {
        name = "nix";
        language-server = {command = "${pkgs.nil}/bin/nil";};
        config.nil.formatting.command = ["${pkgs.alejandra}/bin/alejandra" "-q"];
        auto-format = true;
      }
    ];

    themes = import ./helix_theme.nix {inherit colorscheme;};

    settings = {
      theme = "${colorscheme.slug}";
      #theme = "catppuccin_mocha";

      editor.cursor-shape = {
        insert = "bar";
        normal = "block";
        select = "underline";
      };

      editor.file-picker = {
        hidden = false;
      };

      keys.normal = {
        n = "search_next";
        N = "search_prev";
        A-n = "extend_search_next";
        A-N = "extend_search_prev";

        C-s = ":w";
        C-q = ":q";
        C-w = "rotate_view";
        C-p = "file_picker";
        C-b = "buffer_picker";
        C-A-n = ":bn";
        C-A-p = ":bp";
        y = ["yank" "yank_joined_to_clipboard"];
      };
      keys.insert.j.j = "normal_mode";
      editor = {
        line-number = "absolute";
        indent-guides.render = true;
        color-modes = true;
        true-color = true;
        mouse = true;
      };
    };
  };
}
