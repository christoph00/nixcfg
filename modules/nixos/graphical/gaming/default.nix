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
  cfg = config.internal.graphical.gaming;
in
{

  options.internal.graphical.gaming = {
    enable = mkBoolOpt config.internal.isDesktop "Enable the Gaming.";
    enableStreaming = mkBoolOpt cfg.enable "Enable Game Streaming Host.";
  };

  config = mkIf config.internal.isGraphical {
    chaotic.steam.extraCompatPackages = with pkgs; [
      luxtorpeda
      proton-ge-custom
    ];

    # OpenCL
    chaotic.mesa-git.extraPackages = with pkgs; [
      rocmPackages.clr.icd
      rocmPackages.clr
      mesa_git.opencl
    ];
    environment.variables.RADV_PERFTEST = "sam,video_decode,transfer_queue";

    programs.steam = {
      enable = true;
      gamescopeSession = {
        enable = true; # Gamescope session is better for AAA gaming.
        args = [
          "--immediate-flips"
          "--"
          "bigsteam"
        ];
      };
    };
    programs.gamescope = {
      enable = true;
      capSysNice = false; # capSysNice freezes gamescopeSession for me.
      args = [ ];
      env = lib.mkForce {
        # I set DXVK_HDR in the alternative-sessions script.
        ENABLE_GAMESCOPE_WSI = "1";
      };
      package = pkgs.gamescope_git;
    };

    services.sunshine = mkIf cfg.enableStreaming {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
    };

    # Allows streaming with KMS
    # security.wrappers.sunshine = mkIf cfg.enableStreaming {
    #   source = "${pkgs.sunshine}/bin/sunshine";
    #   capabilities = "cap_sys_admin+pie";
    #   owner = "root";
    #   group = "root";
    # };

  };

}
