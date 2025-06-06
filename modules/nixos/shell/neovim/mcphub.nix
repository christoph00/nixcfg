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
  # uvx = "${pkgs.uv}/bin/uvx";
  # npx = "${pkgs.nodejs}/bin/npx";
  # mcphub-servers = {
  #   nativeMCPServers.neovim.disabledTools = [ ];
  #
  #   mcpServers = {
  #     github = {
  #       command = "${pkgs.github-mcp-server}/bin/github-mcp-server";
  #       args = [
  #         "stdio"
  #       ];
  #       env = {
  #         GITHUB_PERSONAL_ACCESS_TOKEN = "$(awk -F'=' '/^GITHUB_PERSONAL_ACCESS_TOKEN=/ {print $2}' ${config.age.secrets.api-keys.path})";
  #       };
  #     };
  #     fetch = {
  #       command = uvx;
  #       args = [ "-p 3.12 mcp-server-fetch" ];
  #     };
  #     perplexity = {
  #       command = npx;
  #       args = [
  #         "-y"
  #         "server-perplexity-ask"
  #       ];
  #       env = {
  #         PERPLEXITY_API_KEY = "$(awk -F'=' '/^PERPLEXITY_API_KEY=/ {print $2}' ${config.age.secrets.api-keys.path})";
  #       };
  #     };
  #   };
  # };
in
{

  config = mkIf cfg.enable {

    age.secrets.api-keys = mkSecret {
      file = "api-keys";
      owner = "christoph";
    };

    environment.systemPackages = with pkgs; [
      github-mcp-server
    ];
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

    # config = vim.fn.expand("${pkgs.writeText "servers.json" (builtins.toJSON mcphub-servers)}"),
  };

}
