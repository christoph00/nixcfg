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
  cfg = config.chr.apps.nvim;
in {
  options.chr.apps.nvim = with types; {
    enable = mkBoolOpt' config.chr.desktop.enable;
    configRepo = mkOption {
      type = types.str;
      description = "The URI of the remote to be cloned to nvim config directory";
      default = "https://github.com/AstroNvim/AstroNvim.git";
    };

    userConfigRepo = mkOption {
      type = types.nullOr types.str;
      description = "The URI of the remote to be cloned to nvim user config directory";
      # default = "https://github.com/${config.my.github.username}/AstroNvim_user.git";
      default = "https://github.com/christoph00/AstroNvim_user.git";
    };
    defaultEditor = mkBoolOpt' false;
  };

  config = mkIf cfg.enable {
    chr.home = {
      extraOptions = {
        home.sessionVariables = mkIf cfg.defaultEditor {
          EDITOR = "nvim";
        };
        programs.neovim = {
          enable = true;
        };

        home.activation.astrovim = mkIf (cfg.configRepo != null) (lib.hm.dag.entryAfter ["writeBoundary"] ''
          if ! [[ -d ${config.xdg.configHome}/nvim ]]; then
            $DRY_RUN_CMD ${git} clone $VERBOSE_ARG --depth 1 "${cfg.configRepo}" "${config.xdg.configHome}/nvim"
            if [[ -d ${config.xdg.dataHome}/nvim ]]; then
              $DRY_RUN_CMD mv $VERBOSE_ARG "${config.xdg.dataHome}/nvim" "${config.xdg.dataHome}/nvim~"
            fi
            if [[ -d ${config.xdg.stateHome}/nvim ]]; then
              $DRY_RUN_CMD mv $VERBOSE_ARG "${config.xdg.stateHome}/nvim" "${config.xdg.stateHome}/nvim~"
            fi
          fi
        '');

        home.activation.astrovimUser = mkIf (cfg.userConfigRepo != null) (lib.hm.dag.entryAfter ["writeBoundary"] ''
          if ! [[ -d ${config.xdg.configHome}/astronvim ]]; then
            $DRY_RUN_CMD ${git} clone $VERBOSE_ARG --depth 1 "${cfg.userConfigRepo}" "${config.xdg.configHome}/astronvim/lua/user"
          fi
        '');
      };
    };
  };
}
