{pkgs, ...}: {
  programs.helix = {
    enable = true;
    languages = {
      language-server.nixd.command = "nixd";
      language = [
        {
          name = "nix";
          formatter.command = "alejandra";
          auto-format = true;
        }
        {
          name = "bash";
          auto-format = true;
          formatter = {
            command = "${pkgs.shfmt}/bin/shfmt";
            args = ["-i" "2" "-"];
          };
        }

      ];
    };
    settings = {
      theme = "base16_default";
      keys.normal = {
        X = "extend_line_above";
      };
      editor = {
        cursorline = true;
        cursorcolumn = false;
        color-modes = true;
        file-picker.hidden = true;
        lsp = {
          display-messages = true;
          display-inlay-hints = true;
        };
        soft-wrap.enable = true;
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        gutters = ["diagnostics" "line-numbers" "spacer" "diff"];
        statusline = {
          mode-separator = "";
          separator = "";
          left = ["mode" "spinner" "file-type" "diagnostics"];
          center = ["file-name"];
          right = [
            "selections"
            "position"
            "separator"
            "spacer"
            "position-percentage"
          ];
        };
        indent-guides = {
          render = true;
          skip-levels = 1;
        };
      };
    };
  };
}
