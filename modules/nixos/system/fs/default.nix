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
      enable = mkBoolOpt' (config.internal.system.disk.layout == "luks-btrfs");
    };
    xfs = with types; {
      enable = mkBoolOpt' (config.internal.system.disk.layout == "luks-xfs");
    };
    bcachefs = with types; {
      enable = mkBoolOpt' (config.internal.system.disk.layout == "bcachefs");
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
      })
      (mkIf cfg.bcachefs.enable {
      boot = {
              supportedFilesystems = ["bcachefs"];
              kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_stable;
              initrd.availableKernelModules = [
                #        "crypted"
                "aesni_intel"
              ];
            };

            environment.systemPackages = with pkgs; [bcachefs-tools];

      })
      (mkIf cfg.xfs.enable {
        fileSystems = {
          "/mnt/state" = {
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
          "/" = {
            options = [
              "defaults"
              "noatime"
              "nosuid"
              "nodev"
              "mode=755"
            ];
            device = "tmpfs";
          };

        };

      })

    ]
  );
}
