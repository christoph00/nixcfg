{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
in {
  config.programs.nvf.settings.vim.keymaps = [
    # Buffer mappings ========================================================
    {
      key = "<leader>ba";
      mode = "n";
      action = "<Cmd>b#<CR>";
      desc = "Alternate";
    }
    {
      key = "<leader>bd";
      mode = "n";
      action = "<Cmd>lua MiniBufremove.delete()<CR>";
      desc = "Delete";
    }
    {
      key = "<leader>bD";
      mode = "n";
      action = "<Cmd>lua MiniBufremove.delete(0, true)<CR>";
      desc = "Delete!";
    }
    {
      key = "<leader>bs";
      mode = "n";
      action = "<Cmd>lua vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(true, true))<CR>";
      desc = "Scratch";
    }
    {
      key = "<leader>bw";
      mode = "n";
      action = "<Cmd>lua MiniBufremove.wipeout()<CR>";
      desc = "Wipeout";
    }
    {
      key = "<leader>bW";
      mode = "n";
      action = "<Cmd>lua MiniBufremove.wipeout(0, true)<CR>";
      desc = "Wipeout!";
    }

    # Explore/Edit mappings ==================================================
    {
      key = "<leader>ed";
      mode = "n";
      action = "<Cmd>lua MiniFiles.open()<CR>";
      desc = "Directory";
    }
    {
      key = "<leader>ef";
      mode = "n";
      action = "<Cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<CR>";
      desc = "File directory";
    }
    {
      key = "<leader>en";
      mode = "n";
      action = "<Cmd>lua MiniNotify.show_history()<CR>";
      desc = "Notifications";
    }
    {
      key = "<leader>eq";
      mode = "n";
      action = "<Cmd>lua require('custom.quickfix').toggle()<CR>";
      desc = "Quickfix";
    }

    # Find mappings ==========================================================
    {
      key = "<leader>f/";
      mode = "n";
      action = "<Cmd>Pick history scope=\"/<CR>";
      desc = "\"/\" history";
    }
    {
      key = "<leader>f:";
      mode = "n";
      action = "<Cmd>Pick history scope=\":\"<CR>";
      desc = "\":\" history";
    }
    {
      key = "<leader>fa";
      mode = "n";
      action = "<Cmd>Pick git_hunks scope=\"staged\"<CR>";
      desc = "Added hunks (all)";
    }
    {
      key = "<leader>fA";
      mode = "n";
      action = "<Cmd>Pick git_hunks path=\"%\" scope=\"staged\"<CR>";
      desc = "Added hunks (buf)";
    }
    {
      key = "<leader>fb";
      mode = "n";
      action = "<Cmd>Pick buffers<CR>";
      desc = "Buffers";
    }
    {
      key = "<leader>fc";
      mode = "n";
      action = "<Cmd>Pick git_commits<CR>";
      desc = "Commits (all)";
    }
    {
      key = "<leader>fC";
      mode = "n";
      action = "<Cmd>Pick git_commits path=\"%\"<CR>";
      desc = "Commits (buf)";
    }
    {
      key = "<leader>fd";
      mode = "n";
      action = "<Cmd>Pick diagnostic scope=\"all\"<CR>";
      desc = "Diagnostic workspace";
    }
    {
      key = "<leader>fD";
      mode = "n";
      action = "<Cmd>Pick diagnostic scope=\"current\"<CR>";
      desc = "Diagnostic buffer";
    }
    {
      key = "<leader>ff";
      mode = "n";
      action = "<Cmd>Pick files<CR>";
      desc = "Files";
    }
    {
      key = "<leader>fg";
      mode = "n";
      action = "<Cmd>Pick grep_live<CR>";
      desc = "Grep live";
    }
    {
      key = "<leader>fG";
      mode = "n";
      action = "<Cmd>Pick grep pattern=\"<cword>\"<CR>";
      desc = "Grep current word";
    }
    {
      key = "<leader>fh";
      mode = "n";
      action = "<Cmd>Pick help<CR>";
      desc = "Help tags";
    }
    {
      key = "<leader>fH";
      mode = "n";
      action = "<Cmd>Pick hl_groups<CR>";
      desc = "Highlight groups";
    }
    {
      key = "<leader>fl";
      mode = "n";
      action = "<Cmd>Pick buf_lines scope=\"all\"<CR>";
      desc = "Lines (all)";
    }
    {
      key = "<leader>fL";
      mode = "n";
      action = "<Cmd>Pick buf_lines scope=\"current\"<CR>";
      desc = "Lines (buf)";
    }
    {
      key = "<leader>fm";
      mode = "n";
      action = "<Cmd>Pick git_hunks<CR>";
      desc = "Modified hunks (all)";
    }
    {
      key = "<leader>fM";
      mode = "n";
      action = "<Cmd>Pick git_hunks path=\"%\"<CR>";
      desc = "Modified hunks (buf)";
    }
    {
      key = "<leader>fr";
      mode = "n";
      action = "<Cmd>Pick resume<CR>";
      desc = "Resume";
    }
    {
      key = "<leader>fR";
      mode = "n";
      action = "<Cmd>Pick lsp scope=\"references\"<CR>";
      desc = "References (LSP)";
    }
    {
      key = "<leader>fs";
      mode = "n";
      action = "<Cmd>Pick lsp scope=\"workspace_symbol_live\"<CR>";
      desc = "Symbols workspace (live)";
    }
    {
      key = "<leader>fS";
      mode = "n";
      action = "<Cmd>Pick lsp scope=\"document_symbol\"<CR>";
      desc = "Symbols document";
    }
    {
      key = "<leader>fv";
      mode = "n";
      action = "<Cmd>Pick visit_paths cwd=\"\"<CR>";
      desc = "Visit paths (all)";
    }
    {
      key = "<leader>fV";
      mode = "n";
      action = "<Cmd>Pick visit_paths<CR>";
      desc = "Visit paths (cwd)";
    }

    # Git mappings ===========================================================
    {
      key = "<leader>ga";
      mode = "n";
      action = "<Cmd>Git diff --cached<CR>";
      desc = "Added diff";
    }
    {
      key = "<leader>gA";
      mode = "n";
      action = "<Cmd>Git diff --cached -- %<CR>";
      desc = "Added diff buffer";
    }
    {
      key = "<leader>gc";
      mode = "n";
      action = "<Cmd>Git commit<CR>";
      desc = "Commit";
    }
    {
      key = "<leader>gC";
      mode = "n";
      action = "<Cmd>Git commit --amend<CR>";
      desc = "Commit amend";
    }
    {
      key = "<leader>gd";
      mode = "n";
      action = "<Cmd>Git diff<CR>";
      desc = "Diff";
    }
    {
      key = "<leader>gD";
      mode = "n";
      action = "<Cmd>Git diff -- %<CR>";
      desc = "Diff buffer";
    }
    {
      key = "<leader>gl";
      mode = "n";
      action = "<Cmd>Git log --pretty=format:%h\\ %as\\ │\\ %s --topo-order<CR>";
      desc = "Log";
    }
    {
      key = "<leader>gL";
      mode = "n";
      action = "<Cmd>Git log --pretty=format:%h\\ %as\\ │\\ %s --topo-order --follow -- %<CR>";
      desc = "Log buffer";
    }
    {
      key = "<leader>go";
      mode = "n";
      action = "<Cmd>lua MiniDiff.toggle_overlay()<CR>";
      desc = "Toggle overlay";
    }
    {
      key = "<leader>gs";
      mode = "n";
      action = "<Cmd>lua MiniGit.show_at_cursor()<CR>";
      desc = "Show at cursor";
    }
    {
      key = "<leader>gs";
      mode = "x";
      action = "<Cmd>lua MiniGit.show_at_cursor()<CR>";
      desc = "Show at selection";
    }

    # Language mappings ======================================================
    {
      key = "<leader>la";
      mode = "n";
      action = "<Cmd>lua vim.lsp.buf.code_action()<CR>";
      desc = "Actions";
    }
    {
      key = "<leader>ld";
      mode = "n";
      action = "<Cmd>lua vim.diagnostic.open_float()<CR>";
      desc = "Diagnostic popup";
    }
    {
      key = "<leader>lf";
      mode = "n";
      action = "<Cmd>lua require(\"conform\").format({lsp_fallback=true})<CR>";
      desc = "Format";
    }
    {
      key = "<leader>lf";
      mode = "x";
      action = "<Cmd>lua require(\"conform\").format({lsp_fallback=true})<CR>";
      desc = "Format selection";
    }
    {
      key = "<leader>li";
      mode = "n";
      action = "<Cmd>lua vim.lsp.buf.implementation()<CR>";
      desc = "Implementation";
    }
    {
      key = "<leader>lh";
      mode = "n";
      action = "<Cmd>lua vim.lsp.buf.hover()<CR>";
      desc = "Hover";
    }
    {
      key = "<leader>lr";
      mode = "n";
      action = "<Cmd>lua vim.lsp.buf.rename()<CR>";
      desc = "Rename";
    }
    {
      key = "<leader>lR";
      mode = "n";
      action = "<Cmd>lua vim.lsp.buf.references()<CR>";
      desc = "References";
    }
    {
      key = "<leader>ls";
      mode = "n";
      action = "<Cmd>lua vim.lsp.buf.definition()<CR>";
      desc = "Source definition";
    }
    {
      key = "<leader>lt";
      mode = "n";
      action = "<Cmd>lua vim.lsp.buf.type_definition()<CR>";
      desc = "Type definition";
    }

    # Map mappings ===========================================================
    {
      key = "<leader>mf";
      mode = "n";
      action = "<Cmd>lua MiniMap.toggle_focus()<CR>";
      desc = "Focus (toggle)";
    }
    {
      key = "<leader>mr";
      mode = "n";
      action = "<Cmd>lua MiniMap.refresh()<CR>";
      desc = "Refresh";
    }
    {
      key = "<leader>ms";
      mode = "n";
      action = "<Cmd>lua MiniMap.toggle_side()<CR>";
      desc = "Side (toggle)";
    }
    {
      key = "<leader>mt";
      mode = "n";
      action = "<Cmd>lua MiniMap.toggle()<CR>";
      desc = "Toggle";
    }

    # Other mappings =========================================================
    {
      key = "<leader>or";
      mode = "n";
      action = "<Cmd>lua MiniMisc.resize_window()<CR>";
      desc = "Resize to default width";
    }
    {
      key = "<leader>ot";
      mode = "n";
      action = "<Cmd>lua MiniTrailspace.trim()<CR>";
      desc = "Trim trailspace";
    }
    {
      key = "<leader>oz";
      mode = "n";
      action = "<Cmd>lua MiniMisc.zoom()<CR>";
      desc = "Zoom toggle";
    }

    # Session mappings =======================================================
    {
      key = "<leader>sd";
      mode = "n";
      action = "<Cmd>lua MiniSessions.select(\"delete\")<CR>";
      desc = "Delete";
    }
    {
      key = "<leader>sn";
      mode = "n";
      action = "<Cmd>lua MiniSessions.write(vim.fn.input(\"Session name: \"))<CR>";
      desc = "New";
    }
    {
      key = "<leader>sr";
      mode = "n";
      action = "<Cmd>lua MiniSessions.select(\"read\")<CR>";
      desc = "Read";
    }
    {
      key = "<leader>sw";
      mode = "n";
      action = "<Cmd>lua MiniSessions.write()<CR>";
      desc = "Write current";
    }

    # Terminal mappings ======================================================
    {
      key = "<leader>tT";
      mode = "n";
      action = "<Cmd>horizontal term<CR>";
      desc = "Terminal (horizontal)";
    }
    {
      key = "<leader>tt";
      mode = "n";
      action = "<Cmd>vertical term<CR>";
      desc = "Terminal (vertical)";
    }

    # Visits mappings ========================================================
    {
      key = "<leader>vl";
      mode = "n";
      action = "<Cmd>lua MiniVisits.add_label()<CR>";
      desc = "Add label";
    }
    {
      key = "<leader>vL";
      mode = "n";
      action = "<Cmd>lua MiniVisits.remove_label()<CR>";
      desc = "Remove label";
    }
    {
      key = "<leader>vv";
      mode = "n";
      action = "<Cmd>lua MiniVisits.add_label(\"core\")<CR>";
      desc = "Add \"core\" label";
    }
    {
      key = "<leader>vV";
      mode = "n";
      action = "<Cmd>lua MiniVisits.remove_label(\"core\")<CR>";
      desc = "Remove \"core\" label";
    }
  ];
}
