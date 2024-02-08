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
  cfg = config.chr.services.ai;
in {
  options.chr.services.ai = with types; {
    enable = mkBoolOpt false "Enable ai Service.";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [inputs.ollama.packages.${pkgs.system}.cuda pkgs.cudatoolkit pkgs.nvtop];

    services.ollama = {
      enable = true;
      package = inputs.ollama.packages.${pkgs.system}.cuda;
      listenAddress = "0.0.0.0:11434";
    };
    environment.persistence."${config.chr.system.persist.stateDir}" = {
      directories = [
        {
          directory = "/var/lib/ollama";
        }
      ];
    };
  };
}
