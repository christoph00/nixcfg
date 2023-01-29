{
  pkgs,
  config,
  lib,
  ...
}: let
  lspSettings = {
    servers.nix = {
      command = ["${pkgs.nil}/bin/nil"];
      url = "https://github.com/oxalica/nil";
      highlightingModeRegex = "^Nix$";
      rootIndicationFileNames = ["flake.nix"];
     # settings.nil.formatting.command = ["${pkgs.alejandra}/bin/alejandra" "-q"];
    };
  };
in {
  xdg.configFile."kate/lspclient/settings.json".text = lib.generators.toJSON {} lspSettings;
}
