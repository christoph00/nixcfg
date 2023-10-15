{
  lib,
  pkgs,
  config,
  osConfig ? {},
  format ? "unknown",
  ...
}:
with lib.chr; {
  chr = {
    user = {
      enable = true;
    };
    desktop = {
      enable = true;
    };
    apps = {
      cli = true;
    };
  };
}
