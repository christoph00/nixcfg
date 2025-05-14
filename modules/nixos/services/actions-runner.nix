{
  lib,
  flake,
  pkgs,
  config,
  options,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (flake.lib) mkBoolOpt mkSecret;
  cfg = config.svc.actions-runner;
in
{

  options.svc.actions-runner = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {

    age.secrets.actions-runner = mkSecret { file = "actions-runner"; };

    services.gitea-actions-runner.instances.${config.networking.hostName} = {
      enable = true;
      labels = [
        "nix-${config.nixpkgs.hostPlatform}:host"
      ];
      hostPackages = with pkgs; [
        bash
        coreutils
        curl
        gawk
        gitMinimal
        gnused
        bun
        nh
        nixfmt-rfc-style
        wget

      ];
      name = config.networking.hostName;
      url = "https://codeberg.org";
      tokenFile = config.age.secrets.actions-runner.path;
      settings = {
        log.level = "info";
        cache = {
          enabled = true;
          dir = "/var/cache/forgejo-runner/actions";
        };
        runner = {
          capacity = 2;
          timeout = "3h";
        };

      };
    };

  };

}
