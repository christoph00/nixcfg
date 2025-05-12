{
  config,
  flake,
  lib,
  options,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (flake.lib) mkBoolOpt;
  cfg = options.graphical.desktop;
in
{
  options.graphical.desktop = {
    enable = mkBoolOpt config.host.graphical;

  };
  config = mkIf cfg.enable {
    hardware.graphics.enable = true;

    boot.kernelModules = [ "uinput" ];
    services.udev.extraRules = ''
      KERNEL=="uinput", GROUP="input", MODE="0660" OPTIONS+="static_node=uinput"
    '';

  };

}
