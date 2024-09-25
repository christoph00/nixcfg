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
  cfg = config.internal.services.vscode-tunnel;
in

{

  options.internal.services.vscode-tunnel = {
    enable = mkBoolOpt false "Enable VSCode Tunnel Service.";
  };

  config = mkIf cfg.enable {

    services.vscode-server.enable = true;
    services.vscode-server.installPath = "$HOME/.vscode";

    environment.systemPackages = with pkgs; [ vscode ];

    programs.nix-ld.enable = true;

    systemd.user.services.code-tunnel = {
      enable = true;
      description = "Visual Studio Code Tunnel";
      after = [ "network.target" ];
      startLimitIntervalSec = 0;
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = 10;
      };
      environment = {
        NIX_LD_LIBRARY_PATH = "${lib.makeLibraryPath [
          pkgs.stdenv.cc.cc
        ]}";
        NIX_LD = "${pkgs.glibc}/lib/ld-linux-x86-64.so.2";
      };
      script = ''
        ${pkgs.vscode}/lib/vscode/bin/code-tunnel --verbose --log trace --cli-data-dir $HOME/.vscode tunnel service internal-run
      '';
      wantedBy = [ "default.target" ];
    };

  };
}
