{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  helixUnstable = inputs.helix.outputs.packages.${pkgs.system}.helix;
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

    themes = import ./helix_theme.nix {inherit config;};

    settings = {
      theme = "${config.scheme.slug}";
      keys.normal = {
        # kakoune like
        w = "extend_next_word_start";
        b = "extend_prev_word_start";
        e = "extend_next_word_end";
        W = "extend_next_long_word_start";
        B = "extend_prev_long_word_start";
        E = "extend_next_long_word_end";

        n = "search_next";
        N = "search_prev";
        A-n = "extend_search_next";
        A-N = "extend_search_prev";
        # ----------------

        # syntax tree maniuplation
        A-j = "expand_selection";
        A-k = "shrink_selection";
        A-h = "select_prev_sibling";
        A-l = "select_next_sibling";
        # ----------------

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
