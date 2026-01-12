{
  lib,
  config,
  flake,
  ...
}: let
  inherit (lib) mkIf mkDefault;
  inherit (flake.lib) mkBoolOpt;
in {
  imports = [
    ./n8n.nix
    ./sillytavern.nix
    ./qdrant.nix
  ];
  options.cnt = {
    enable = mkBoolOpt false;
  };
  config = mkIf config.cnt.enable {
    virt.podman = true;
  };
}
