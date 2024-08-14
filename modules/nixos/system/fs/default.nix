{
  lib,
  pkgs,
  inputs,

  config,

  ...
}:

with builtins;
with lib;
with lib.internal;

let
  cfg = config.internal.system.fs;
  state = config.internal.system.state;
in
{

  options.internal.system.fs = {
    btrfs = with types; {
      enable = mkBoolOpt' false;
    };
    xfs = with types; {
      enable = mkBoolOpt' false;
    };
  };

  config = (
    mkMerge [
      (mkIf cfg.btrfs.enable {
        services.btrfs.autoScrub = {
          enable = true;
          interval = "monthly";
          fileSystems = [
            "/nix"
            "/state"
            "/home"
          ];
        };
        filesystems."/state".neededForBoot = true;
      })
      (mkIf cfg.xfs.enable {
        filesystems = {
          "/state" = {
            neededForBoot = true;
          };
          "/nix" = {
            device = "/mnt/state/nix";
            options = [ "bind" ];
            neededForBoot = true;
          };
          "/home" = {
            device = "/mnt/state/home";
            options = [ "bind" ];
          };

        };

      })

    ]
  );
}
