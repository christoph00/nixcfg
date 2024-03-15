{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.desktop.ironbar;
in {
  options.chr.desktop.ironbar = with types; {
    enable = mkBoolOpt false "Whether or not enable Ironbar.";
    package = mkOption {
      type = types.package;
      default = inputs.ironbar.packages.${pkgs.system}.default;
      defaultText = literalExpression "inputs.ironbar.packages.${pkgs.system}.default";
      description = lib.mdDoc ''
        ironbar package to use.
      '';
    };
  };

  config = mkIf cfg.enable {
    chr.home.extraOptions = {
      programs.ironbar = {
        enable = true;
        config = {};
        systemd = false;
        package = cfg.package;
      };
    };
  };
}
