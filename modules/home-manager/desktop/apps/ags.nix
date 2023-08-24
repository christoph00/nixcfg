{
  config,
  osConfig,
  pkgs,
  lib,
  inputs',
  ...
}: let
  compileSCSS = name: source: "${
    pkgs.runCommandLocal name {} ''
      mkdir -p $out
      ${lib.getExe pkgs.rsass} '${source}' > $out/${name}.css
    ''
  }/${name}.css";
in {
  config = lib.mkIf (osConfig.nos.desktop.bar == "ags") {
    home.packages = [
      inputs'.ags.packages.default
    ];
  };
}
