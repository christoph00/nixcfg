{
  lib,
  config,
  flake,
  ...
}:
let
  inherit (lib) mkIf mkDefault;
  inherit (flake.lib) mkBoolOpt;
in
{
  imports = [
    ./n8n.nix
    ./cliproxy.nix
    ./sillytavern.nix
    ./stalwart.nix
    ./openclaw.nix
    ./qdrant.nix
    ./home-assistant.nix
    ./music-assistant.nix
    ./beszel.nix
    ./gonic.nix
    ./media-pod.nix
    ./lobechat.nix
  ];
  options.cnt = {
    enable = mkBoolOpt false;
  };
  config = mkIf config.cnt.enable {
    virt.podman = true;
  };
}
