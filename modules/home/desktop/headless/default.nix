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

    wayland.windowManager.sway = {
      enable = true;
      systemd.enable = true;
      wrapperFeatures.gtk = true;
      startup = [
        {
          command = "${pkgs.wlr-randr}/bin/wlr-randr --output HDMI-A-1 --off --output HEADLESS-1 --custom-mode 1920x1080@60";
        }

        { command = "${pkgs.sunshine}/bin/sunshine"; }
      ];

      config = {
        output.HEADLESS-1 = {
          mode = "1920x1080@60";
          pos = "0 0";
        };
      };
    };
  };
}
