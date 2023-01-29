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
    };
  };
in {
  xdg.configFile."kate/lspclient/settings.json".text = lib.generators.toJSON {} lspSettings;
}
