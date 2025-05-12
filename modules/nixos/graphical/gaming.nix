{
  lib,
  flake,
  pkgs,
  options,
  config,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (flake.lib) mkBoolOpt;
  cfg = config.graphical.gaming;
in
{
  options.graphical.gaming = {
    enable = mkBoolOpt false;
  };
  config = mkIf cfg.enable {

    boot.kernelModules = [ "ntsync" ];

    services.udev.extraRules = ''
      KERNEL=="ntsync", MODE="0644"
    '';

    environment.systemPackages = with pkgs; [
      steam
      proton-ge-custom
      protonup-qt
      gamemode
      gamemoderun
      openmw
      bottles
    ];
  };
}
