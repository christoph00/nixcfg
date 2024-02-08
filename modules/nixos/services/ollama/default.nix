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
  cfg = config.chr.services.ollama;
in {
  options.chr.services.ollama = with types; {
    enable = mkBoolOpt' false;
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
          directory = "/var/lib/private/ollama";
        }
      ];
    };
  };
}
