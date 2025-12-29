{
  lib,
  config,
  flake,
  pkgs,
  perSystem,
  ...
}:
let
  inherit (lib) mkIf mkForce;
  inherit (flake.lib) mkSecret mkBoolOpt;
in
{
  options.svc.litellm = {
    enable = mkBoolOpt false;
  };
  config = mkIf config.svc.litellm.enable {
    age.secrets."litellm-env" = mkSecret {
      file = "litellm-env";
    };
    sys.state.directories = [ "/var/lib/private/litellm" ];

    services.litellm = {
      enable = true;
      package = perSystem.nixpkgs-unstable.litellm.overrideAttrs (old: rec {
        version = "1.80.10.rc.5";
        src = perSystem.nixpkgs-unstable.fetchFromGitHub {
          owner = "BerriAI";
          repo = "litellm";
          rev = "v${version}";
          hash = "sha256-lVNRjDgG+yZR4HfEUnmY1nO1WiukR9aYSBpn0M1JHBc=";
        };
        pythonRelaxDeps = [
          "grpcio"
          "aiohttp"
          "tiktoken"
          "tokenizers"
          "transformers"
          "openai"
        ];
        passthru = old.passthru // {
          python = old.python.override {
            self = old.python;
            packages = old.python.packages ++ [ perSystem.nixpkgs-unstable.python313Packages.grpcio_1_66 ];
          };
        };
      });
      port = 3032;
      host = config.network.wireguard.ip;
      settings = {
        litellm_settings = {
          drop_params = true;
          set_verbose = false;
          timeout = 60;
          num_retries = 2;
          check_provider_endpoint = true;
          # MCP Aliases - Map aliases to server names for easier tool access
          mcp_aliases = {
            "github" = "github_mcp_server";
            "deepwiki" = "deepwiki_mcp_server";
          };
          mcp_servers = {
            deepwiki_mcp = {
              url = "https://mcp.deepwiki.com/mcp";
            };
            playwright = {
              transport = "stdio";
              command = "${perSystem.mcp-servers.playwright-mcp}/bin/mcp-server-playwright";
              args = [
                "--browser"
                "chrome"
                "--executable-path"
                "${pkgs.chromium}/bin/chromium"
              ];
            };

          };
        };
        general_settings = {
          master_key = "os.environ/LITELLM_API_KEY";
        };
        model_list = [
          {
            model_name = "perplexity-sonar-deep-research";
            litellm_params = {
              model = "perplexity/sonar-deep-research";
              api_key = "os.environ/PERPLEXITYAI_API_KEY";
            };
          }
          {
            model_name = "perplexity-sonar-reasoning-pro";
            litellm_params = {
              model = "perplexity/sonar-reasoning-pro";
              api_key = "os.environ/PERPLEXITYAI_API_KEY";
            };
          }
          {
            model_name = "perplexity-sonar-reasoning";
            litellm_params = {
              model = "perplexity/sonar-reasoning";
              api_key = "os.environ/PERPLEXITYAI_API_KEY";
            };
          }
          {
            model_name = "perplexity-sonar-pro";
            litellm_params = {
              model = "perplexity/sonar-pro";
              api_key = "os.environ/PERPLEXITYAI_API_KEY";
            };
          }
          {
            model_name = "perplexity-sonar";
            litellm_params = {
              model = "perplexity/sonar";
              api_key = "os.environ/PERPLEXITYAI_API_KEY";
            };
          }
          {
            model_name = "perplexity-r1-1776";
            litellm_params = {
              model = "perplexity/r1-1776";
              api_key = "os.environ/PERPLEXITYAI_API_KEY";
            };
          }
          {
            model_name = "glm-4.6";
            litellm_params = {
              model = "zai/glm-4.6";
              api_key = "os.environ/ZAI_API_KEY";
              api_base = "https://api.z.ai/api/coding/paas/v4";
            };
          }
          {
            model_name = "glm-4.5";
            litellm_params = {
              model = "zai/glm-4.5";
              api_key = "os.environ/ZAI_API_KEY";
              api_base = "https://api.z.ai/api/coding/paas/v4";
            };
          }
          {
            model_name = "glm-4.5-air";
            litellm_params = {
              model = "zai/glm-4.5-air";
              api_key = "os.environ/ZAI_API_KEY";
              api_base = "https://api.z.ai/api/coding/paas/v4";
            };
          }
          {
            model_name = "openrouter/*";
            litellm_params = {
              model = "openrouter/*";
              api_key = "os.environ/OPENROUTER_API_KEY";
            };
          }
          {
            model_name = "github_copilot/gpt-4";
            litellm_params = {
              model = "github_copilot/gpt-4";
              extra_headers = {
                "Editor-Version" = "vscode/1.85.1";
                "Copilot-Integration-Id" = "vscode-chat";
              };
            };
          }
          {
            model_name = "github_copilot/text-embedding-ada-002";
            model_info = {
              mode = "embedding";
            };
            litellm_params = {
              model = "github_copilot/text-embedding-ada-002";
              extra_headers = {
                "Editor-Version" = "vscode/1.85.1";
                "Copilot-Integration-Id" = "vscode-chat";
              };
            };
          }
        ];
      };
      environment = {
        NO_DOCS = "True";
        NO_REDOC = "True";
        DISABLE_ADMIN_UI = "True";
        HOME = "/var/lib/litellm";
        SCARF_NO_ANALYTICS = "True";
        XDG_CACHE_HOME = "/var/cache/litellm";
      };
      environmentFile = config.age.secrets."litellm-env".path;
    };

  };
}
