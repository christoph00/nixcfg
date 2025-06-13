{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
in
{
  config = mkIf config.programs.nvf.enable {
    home.packages = [ pkgs.himalaya ];

    programs.nvf.settings.vim.lazy.plugins."himalaya-vim" = {
      package = pkgs.vimPlugins.himalaya-vim;
      setupModule = "himalaya";
      cmd = [ "Himalaya" ];
      # after = ''
      #   vim.g.himalaya_executable = "${pkgs.himalaya}/bin/himalaya}"
      # '';
    };

  };
}
