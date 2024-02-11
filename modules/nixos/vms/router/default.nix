{
  inputs,
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.vms.router;
in {
  options.chr.vms.router = with types; {
    enable = mkBoolOpt' false;
  };

  config = mkIf cfg.enable {
    microvm.vms.router = {
      inherit pkgs;
      config = {
        system = {inherit (config.system) stateVersion;};

        microvm.shares = [
          {
            source = "/nix/store";
            mountPoint = "/nix/.ro-store";
            tag = "ro-store";
            proto = "virtiofs";
          }
        ];
      };
    };
  };
}
