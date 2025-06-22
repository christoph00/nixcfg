{
  flake,
  lib,
  config,
  pkgs,
  perSystem,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (flake.lib) mkBoolOpt mkIntOpt mkSecret;
  cfg = config.programs.nvf;
in
{

  config = mkIf cfg.enable {

    age.secrets.api-keys = mkSecret {
      file = "api-keys";
      owner = "christoph";
    };

    home.packages = with perSystem.mcp-servers; [
      # mcp-server-fetch
      # mcp-server-brave-search
      mcp-server-filesystem
      # mcp-server-memory
      # playwright-mcp
      # mcp-server-gdrive

    ];
    # ++ [
    # pkgs.github-mcp-server
    #   perSystem.mcp-nixos.default
    #   perSystem.self.basic-memory
    #   perSystem.self.vector-code
    # ];
    programs.nvf.settings.vim.extraPlugins = {
      mcphub = {
        package = perSystem.mcphub-nvim.default;
        # The `build` step for npm install is ignored here; user handles CLI install.
        # The `config` function from Lua spec is translated to `setup` string:
        setup = ''
          local status_ok, mcphub = pcall(require, "mcphub")
          if not status_ok then
            vim.notify("mcphub.nvim plugin could not be required. Ensure mcp-hub CLI is installed globally and in PATH.", vim.log.levels.ERROR)
            return
          end
          mcphub.setup({
            port = 6565,
            cmd = "${perSystem.mcphub.default}/bin/mcp-hub"

          })
        '';
      };
    };
  };

}
