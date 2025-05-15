{
  flake,
  lib,
  options,
  config,
  ...
}:
let
  inherit (flake.lib) mkOpt;
  inherit (lib.types) enum int;
  cfg = config.hw;
in
{
  options.hw = {
    gpu = mkOpt (enum [
      "amd"
      "nvidia"
      "intel"
      "vm"
      "other"
    ]) "other";
    ram = mkOpt int 1;
    cpu = mkOpt (enum [
      "intel"
      "amd"
      "other"
    ]) "intel";
  };
  config = {
    hardware.cpu.intel.updateMicrocode = cfg.cpu == "intel";
    hardware.cpu.amd.updateMicrocode = cfg.cpu == "amd";

  };

}
