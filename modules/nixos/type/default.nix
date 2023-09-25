{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.type;
in {
  options.chr.type = mkOption {
    type = types.enum ["laptop" "desktop" "server" "vm"];
  };

  config = mkMerge [
    (mkIf (cfg == "server") {
      })

    (mkIf (cfg == "desktop" || cfg == "laptop") {
      chr.apps.firefox.enable = mkDefault true;
      chr.system.filesystem = {
        enable = mkDefault true;
        btrfs = mkDefault true;
        persist = mkDefault true;
        mainDisk = mkDefault "/dev/nvme0n1p3";
        efiDisk = mkDefault "/dev/nvme0n1p1";
        rootOnTmpfs = mkDefault true;
      };
    })
  ];
}
