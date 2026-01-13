{lib, ...}: {
  config.programs.nvf.settings.vim = {
    assistant = {
      codecompanion-nvim = {
        enable = true;
        setupOpts = {
          display.chat.show_settings = true;
          strategies = {
            chat = {
              adapter = "openrouter_mimo";
            };
            inline = {
              adapter = "copilot";
            };
            cmd = {
              adapter = "openrouter_mimo";
            };
          };
          # adapters = lib.mkLuaInline ''
          #   {
          #    openrouter_mimo = function()
          #      return require("codecompanion.adapters").extend("openai_compatible", { env = { url = "https://openrouter.ai/api", api_key = "OPENROUTER_API_KEY", chat_url = "/v1/chat/completions", }, schema = { model = { default = "xiaomi/mimo-v2-flash:free", }, }, })
          #    end
          #   }
          # '';
        };
      };
      copilot = {
        enable = true;
        mappings = {
          suggestion = {
            accept = "<C-f>";
            acceptWord = "<C-j>";
            dismiss = "<C-]>";
          };
        };
        setupOpts = {
          suggestion = {
            enabled = true;
            auto_trigger = true;
          };
        };
      };
    };
  };
}
