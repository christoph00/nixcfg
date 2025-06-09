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
    hjem.users.christoph.rum.programs.ghostty = {
      enable = true;
    };
  };
}
