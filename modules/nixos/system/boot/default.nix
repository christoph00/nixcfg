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
    secureBoot = mkBoolOpt' false;
    silentBoot = mkBoolOpt' config.internal.isGraphical;
    encryptedRoot = mkBoolOpt' true;
    #cryptName = mkStrOpt "cryptroot";
    #secretFile = mkStrOpt "../../../../${system}/${config.networking.hostName}/main.jwe";
  };

  config = (
    mkMerge [
      {
        boot.initrd.systemd.enable = true;
        boot.loader.systemd-boot.enable = true;
        boot.loader.systemd-boot.netbootxyz.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;

        # secure boot configs are kept here in the common
        # module because secureBoot must be set to false
        # for the first system boot.

        # sbctl for debugging and troubleshooting Secure Boot.
        # tpm2-tss for interacting with the tpm secure enclave.
        environment.systemPackages = [
          pkgs.sbctl
          pkgs.tpm2-tss
        ];

        # secureboot keys are generated manually after first boot
        # and stored here.
        # internal.features.impermanence.directories = [ "/etc/secureboot" ];
      }
      (mkIf cfg.secureBoot {
        # Lanzaboote currently replaces the systemd-boot module.
        # This setting is usually set to true in configuration.nix
        # generated at installation time. So we force it to false
        # for now.
        boot.initrd.availableKernelModules = [
          "tpm-crb"
          "tpm-tis"
        ];
        boot.loader.systemd-boot.enable = mkForce false;
        boot.lanzaboote = {
          enable = true;
          pkiBundle = "/etc/secureboot";
        };
      })
      (mkIf cfg.encryptedRoot {
        # boot.initrd.clevis = {
        #   enable = true;
        #   devices."${cfg.cryptName}".secretFile = cfg.secretFile;
        # };
        boot.initrd.systemd.enableTpm2 = true;
      })

      (mkIf cfg.silentBoot {
        boot.kernelParams = [
          "quiet"
          "udev.log_level=3"
          "splash"
        ];
        boot.initrd.verbose = false;
        boot.consoleLogLevel = 0;
        boot.loader.timeout = 0;

        boot.plymouth.enable = true;
        boot.plymouth.theme = "nixos-bgrt";
        boot.plymouth.themePackages = [ pkgs.nixos-bgrt-plymouth ];
      })
    ]
  );
}
