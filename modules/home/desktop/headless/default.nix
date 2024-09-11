{
  options,
  config,
  lib,
  pkgs,
  namespace,
  inputs,
  ...
}:
let
  inherit (lib)
    types
    listOf
    mkIf
    mkMerge
    mkDefault
    mkOption
    optional
    asserts
    getExe
    ;

  inherit (lib.internal) mkBoolOpt;
  cfg = config.profiles.internal.desktop.headless;

in
{
  options.profiles.internal.desktop.headless = with types; {
    enable = mkBoolOpt false "Enable Headless Desktop";
    autorun = mkBoolOpt true "Auto Start Service";
    vnc = {
      addr = mkOption {
        type = types.str;
        default = "0.0.0.0";
        description = ''
          Which address should wayvnc listen to.
        '';
      };
      maxFps = mkOption {
        type = types.int;
        default = 30;
        description = ''
          Set the rate limit.
        '';
      };
      port = mkOption {
        type = types.int;
        default = 5900;
        description = ''
          Set the port to listen on.
        '';
      };
    };
  };

  config = mkIf cfg.enable {

    home.packages = [
      pkgs.wlr-randr
    ];
  };
}
