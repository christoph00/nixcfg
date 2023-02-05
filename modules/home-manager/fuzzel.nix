{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.fuzzel;
  iniFormat = pkgs.formats.ini {};
in {
  options.programs.fuzzel = {
    enable = mkEnableOption "Fuzzel Menu";

    package = mkOption {
      type = types.package;
      default = pkgs.fuzzel;
      defaultText = literalExpression "pkgs.fuzzel";
      description = "The fuzzel package to install";
    };

    settings = mkOption {
      type = iniFormat.type;
      default = {};
      description = ''
        Configuration written to
        <filename>$XDG_CONFIG_HOME/fuzzel/fuzzel.ini</filename>. See <link
        xlink:href="https://codeberg.org/dnkl/fuzzel/src/branch/master/fuzzel.ini"/>
        for a list of available options.
      '';
      example = literalExpression ''
        {
          main = {
            terminal = "foot -e";

            font = "Fira Code:size=11";
            dpi-aware = "yes";
          };

          border = {
            radius = 20;
          };
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions = [(hm.assertions.assertPlatform "programs.fuzzel" pkgs platforms.linux)];

    home.packages = [cfg.package];

    xdg.configFile."fuzzel/fuzzel.ini" = mkIf (cfg.settings != {}) {
      source = iniFormat.generate "fuzzel.ini" cfg.settings;
    };
  };
}
