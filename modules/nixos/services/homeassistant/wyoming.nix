{
  config,
  lib,
  pkgs,
  ...
}:

with builtins;
with lib;
with lib.internal;

let
  cfg = config.internal.services.homeassistant.wyoming-openai;
in
{
  options.internal.services.homeassistant.wyoming-openai = {

    enable = mkBoolOpt config.internal.isSmartHome "Enable wyoming-openai Server.";
    port = lib.mkOption {
      type = lib.types.port;
      default = 10300;
      description = "Port to listen on";
    };

    openaiApiKeyFile = lib.mkOption {
      type = lib.types.str;
      default = config.age.secrets.wyoming-openai.path;
      description = "age-encrypted file containing OPENAI_API_KEY";
    };

  };

  config = lib.mkIf cfg.enable {

    age.secrets.wyoming-openai = {
      file = ../../../../secrets/wyoming-openai.env;
      owner = "wyoming-openai";
      group = "wyoming-openai";
      mode = "0400";
    };

    systemd.services.wyoming-openai = {
      description = "Wyoming OpenAI Server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.internal.wyoming-openai}/bin/wyoming-openai --port ${toString cfg.port}";
        Restart = "on-failure";
        DynamicUser = true;
        ProtectSystem = "strict";
        EnvironmentFile = "${cfg.openaiApiKeyFile}";
        Environment = "OPENAI_API_KEY=%d/OPENAI_API_KEY";
        LoadCredential = "OPENAI_API_KEY:${cfg.openaiApiKeyFile}";
      };
    };
  };
}
