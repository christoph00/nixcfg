{
  flake,
  inputs,
  lib,
  pkgs,
  config,

  ...
}:

with builtins;
with lib;
with flake.lib;

let
  cfg = config.sys;
in
{
  imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

  options.sys.boot = with types; {
    enable = mkBoolOpt true;
    secureBoot = mkBoolOpt false;
    silentBoot = mkBoolOpt false;
    encryptedRoot = mkBoolOpt true;
    #cryptName = mkStrOpt "cryptroot";
    #secretFile = mkStrOpt "../../../../${system}/${config.networking.hostName}/main.jwe";
  };

  config = mkIf cfg.boot.enable (mkMerge [
    {
      boot = {
        initrd = {
          compressor = "zstd";
          compressorArgs = [
            "-19"
            "-T0"
          ];
          systemd = enabled;
        };
        loader = {
          systemd-boot = {
            enable = true;
            netbootxyz = enabled;
          };
          efi.canTouchEfiVariables = true;
          systemd-boot.configurationLimit = 5;
          grub = disabled;
        };
      };
      # secure boot configs are kept here in the common
      # module because secureBoot must be set to false
      # for the first system boot.

      # sbctl for debugging and troubleshooting Secure Boot.
      # tpm2-tss for interacting with the tpm secure enclave.

      # secureboot keys are generated manually after first boot
      # and stored here.
      # internal.features.impermanence.directories = [ "/etc/secureboot" ];
    }
    (mkIf cfg.boot.secureBoot {
      # Lanzaboote currently replaces the systemd-boot module.
      # This setting is usually set to true in configuration.nix
      # generated at installation time. So we force it to false
      # for now.
      #
      environment.systemPackages = [
        pkgs.sbctl
        pkgs.tpm2-tss
      ];
      boot = {
        initrd.availableKernelModules = [
          "tpm-crb"
          "tpm-tis"
        ];
        loader.systemd-boot.enable = mkForce false;
        loader.grub.enable = mkForce false;
        lanzaboote = {
          enable = true;
          pkiBundle = "/etc/secureboot";
        };
      };

      sys.state.directories = [ "/etc/secureboot" ];

    })
    (mkIf cfg.boot.encryptedRoot {
      # boot.initrd.clevis = {
      #   enable = true;
      #   devices."${cfg.cryptName}".secretFile = cfg.secretFile;
      # };
      boot.initrd.systemd.tpm2 = enabled;
    })

    (mkIf cfg.boot.silentBoot {
      boot = {
        kernelParams = [
          "quiet"
          # kernel log message level
          "loglevel=3" # 1: system is unusable | 3: error condition | 7: very verbose
          "udev.log_level=3"
          "rd.udev.log_level=3"
          "systemd.show_status=auto"
          "rd.systemd.show_status=auto"
          "vt.global_cursor_default=0"
        ];
        initrd.verbose = false;
        consoleLogLevel = 0;
        loader.timeout = 0;
      };

    })
  ]);
}
