{
  config,
  lib,
  flake,
  ...
}: let
  inherit (flake.lib) enabled;
in {
  config.programs.nvf.settings.vim.mini = {
    basics = {
      enable = true;
      setupOpts = {
        options = {
          # Basic options ('number', 'ignorecase', and many more)
          basic = true;
        };
        mappings = {
          # Move cursor in Insert, Command, and Terminal mode with <M-hjkl>
          move_with_alt = true;
        };
      };
    };
    icons = enabled;
    notify = enabled;
    surround = {
      enable = true;
      setupOpts = {
        mappings = {
          add = "sa";
          delete = "sd";
          replace = "sr";
          find = "sf";
          find_left = "sF";
          highlight = "sh";
          update_n_lines = "sn";
        };
        n_lines = 1000;
      };
    };
    pairs = enabled;

    sessions = {
      enable = true;
      setupOpts = {
        autoread = true;
      };
    };
    starter = {
      enable = true;
    };

    tabline = {
      enable = true;
    };

    statusline = {
      enable = true;
    };

    git = enabled;
    diff = enabled;
    move = {
      enable = true;
    };
    bracketed = enabled;
    bufremove = enabled;
    cursorword = enabled;
    misc = enabled;
    extra = enabled;

    ai = {
      enable = true;
    };
    align = enabled;
    comment = enabled;
    hipatterns = {
      enable = true;
    };
    indentscope = enabled;
    jump = enabled;
    jump2d = enabled;
    operators = enabled;
    splitjoin = enabled;
    trailspace = enabled;

    files = {
      enable = true;
      setupOpts = {
        windows = {
          preview = true;
        };
      };
    };

    pick = {
      enable = true;
    };

    visits = enabled;
  };
}
