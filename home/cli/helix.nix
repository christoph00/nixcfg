{...}: {
  programs.helix = {
    enable = true;
    languages = {
      language-server.nixd.command = "nixd";
      language = [
        {
          name = "nix";
          formatter.command = "alejandra";
          auto-format = true;
          # language-servers = [ "nixd" ];
        }
      ];
    };
    settings = {
      keys.normal = {
        X = "extend_line_above";
      };
      editor = {
        cursorline = true;
        cursorcolumn = true;
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
        statusline = {
          left = ["mode" "spinner" "file-type" "diagnostics"];
          center = ["file-name"];
          right = [
            "selections"
            "position"
            "separator"
            "spacer"
            "position-percentage"
          ];
          separator = "|";
        };
        indent-guides = {
          render = true;
          skip-levels = 1;
        };
      };
    };
  };
}