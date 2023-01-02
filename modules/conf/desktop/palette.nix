{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.conf.theme.palette;
in {
  options.conf.theme.palette.enable = mkEnableOption "Enable Palette Preview";
  config = mkIf cfg.enable {
    environment.etc = {
      "theme/palette.html".source = config.scheme {
        template = builtins.readFile ./palette.mustache;
        extension = ".html";
      };
    };
  };
}
