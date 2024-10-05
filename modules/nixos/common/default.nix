{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib
, # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs
, # You also have access to your flake's inputs.
  inputs
, # Additional metadata is provided by Snowfall Lib.
  namespace
, # The namespace used for your flake, defaulting to "internal" if not set.
  system
, # The system architecture for this host (eg. `x86_64-linux`).
  target
, # The Snowfall Lib target for this system (eg. `x86_64-iso`).
  format
, # A normalized name for the system target (eg. `iso`).
  virtual
, # A boolean to determine whether this system is a virtual target using nixos-generators.
  systems
, # An attribute map of your defined hosts.

  # All other arguments come from the module system.
  config
, ...
}:

with builtins;
with lib;
with lib.internal;

{

  config = {

    hardware.enableRedistributableFirmware = true;
    security = {

      # enable realtime capabilities to user processes
      rtkit.enable = true;


      sudo.enable = false;

      doas = {
        enable = true;
        wheelNeedsPassword = false;
        extraRules = [
          {
            groups = [ "wheel" ];
            noPass = true;
            keepEnv = true;
          }
        ];
      };
    };

    console = {
      earlySetup = true;
      useXkbConfig = true;
    };
    #system.etc.overlay.enable = lib.mkDefault true;
    services.userborn.enable = lib.mkDefault true;

    # Random perl remnants
    system.disableInstallerTools = lib.mkDefault true;
    programs.less.lessopen = lib.mkDefault null;
    programs.command-not-found.enable = lib.mkDefault false;
    boot = {

      #environment.memoryAllocator.provider = "mimalloc";
      #nixpkgs.overlays = [ (_: prev: { dhcpcd = prev.dhcpcd.override { enablePrivSep = false; }; }) ];
      initrd.systemd.enable = lib.mkDefault true;
      enableContainers = lib.mkDefault false;
      loader.grub.enable = lib.mkDefault false;
    };
    environment.defaultPackages = lib.mkDefault [ ];
    documentation.info.enable = lib.mkDefault false;

    # Check that the system does not contain a Nix store path that contains the
    # string "perl".
    # system.forbiddenDependenciesRegexes = [ "perl" ];

    # Re-add nixos-rebuild to the systemPackages that was removed by the
    # `system.disableInstallerTools` option.
    #environment.systemPackages = [ pkgs.nixos-rebuild ];
  };

}
