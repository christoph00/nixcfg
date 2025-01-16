{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib,
  # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs,
  # You also have access to your flake's inputs.
  inputs,

  # Additional metadata is provided by Snowfall Lib.
  namespace, # The namespace used for your flake, defaulting to "internal" if not set.
  system, # The system architecture for this host (eg. `x86_64-linux`).
  target, # The Snowfall Lib target for this system (eg. `x86_64-iso`).
  format, # A normalized name for the system target (eg. `iso`).
  virtual, # A boolean to determine whether this system is a virtual target using nixos-generators.
  systems, # An attribute map of your defined hosts.

  # All other arguments come from the module system.
  config,

  ...
}:

with builtins;
with lib;
with lib.internal;

let
  cfg = config.internal.system.boot;
in
{

  options.internal.system.boot = with types; {
    enable = mkBoolOpt' true;
    secureBoot = mkBoolOpt' false;
    silentBoot = mkBoolOpt' config.internal.isGraphical;
    encryptedRoot = mkBoolOpt' true;
    #cryptName = mkStrOpt "cryptroot";
    #secretFile = mkStrOpt "../../../../${system}/${config.networking.hostName}/main.jwe";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      boot.initrd = {
        compressor = "zstd";
        compressorArgs = [
          "-19"
          "-T0"
        ];
        systemd.enable = true;
      };
      boot.loader.systemd-boot.enable = true;
      boot.loader.systemd-boot.netbootxyz.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      boot.loader.systemd-boot.configurationLimit = 5;

          boot = {
      initrd.systemd.enable = lib.mkDefault true;
      enableContainers = lib.mkDefault false;
      loader.grub.enable = lib.mkDefault false;
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
    (mkIf cfg.secureBoot {
      # Lanzaboote currently replaces the systemd-boot module.
      # This setting is usually set to true in configuration.nix
      # generated at installation time. So we force it to false
      # for now.
      #
      environment.systemPackages = [
        pkgs.sbctl
        pkgs.tpm2-tss
      ];
      boot.initrd.availableKernelModules = [
        "tpm-crb"
        "tpm-tis"
      ];
      boot.loader.systemd-boot.enable = mkForce false;
      boot.lanzaboote = {
        enable = true;
        pkiBundle = "/etc/secureboot";
      };
      internal.system.state.directories = [ "/etc/secureboot" ];

      # fix error units failed: systemd-hibernate-clear.service https://github.com/systemd/systemd/pull/35497
      systemd.package = pkgs.systemd.overrideAttrs (old: {
        patches = old.patches ++ [
          (pkgs.fetchurl {
            url = "https://github.com/wrvsrx/systemd/compare/tag_fix-hibernate-resume%5E...tag_fix-hibernate-resume.patch";
            hash = "sha256-Z784xysVUOYXCoTYJDRb3ppGiR8CgwY5CNV8jJSLOXU=";
          })
        ];
      });
    })
    (mkIf cfg.encryptedRoot {
      # boot.initrd.clevis = {
      #   enable = true;
      #   devices."${cfg.cryptName}".secretFile = cfg.secretFile;
      # };
      boot.initrd.systemd.tpm2.enable = true;
    })

    (mkIf cfg.silentBoot {
      boot.kernelParams = [

        "quiet"

        # kernel log message level
        "loglevel=3" # 1: system is unusable | 3: error condition | 7: very verbose

        "udev.log_level=3"
        "rd.udev.log_level=3"

        "systemd.show_status=auto"
        "rd.systemd.show_status=auto"
        "vt.global_cursor_default=0"
      ];
      boot.initrd.verbose = false;
      boot.consoleLogLevel = 0;
      boot.loader.timeout = 0;

    })
  ]);
}
