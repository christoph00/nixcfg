{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
in
{
  config = mkIf config.desktop.enable {
    home.rum.programs.ghostty = {
      enable = true;
    };
  };
}
