{
  pkgs,
  input,
  lib,
  flake,
  config,
  options,
  ...
}:
let
  inherit (flake.lib) mkBoolOpt;
  inherit (lib) mkIf;
  cfg = config.desktop;
  switch-resolution = pkgs.writeShellScriptBin "switch-resolution" ''
    WIDTH=''${SUNSHINE_CLIENT_WIDTH:-1920}
    HEIGHT=''${SUNSHINE_CLIENT_HEIGHT:-1080}
    FPS=''${SUNSHINE_CLIENT_FPS:-60}.000

    if [ "$1" == "reset" ]; then
      swaymsg output HEADLESS-1 resolution 1920x1080@60
    else
      swaymsg output HEADLESS-1 resolution ''${WIDTH}x''${HEIGHT}@''${FPS}Hz
    fi
  '';
in
{
  options.desktop = {
    remote = mkBoolOpt false;
  };
  config = mkIf cfg.remote {
    services.udev.extraRules = ''
      KERNEL=="uinput", GROUP="input", MODE="0666", OPTIONS+="static_node=uinput"
    '';
    environment.systemPackages = [ switch-resolution ];
    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = false;
      openFirewall = true;
    };

    systemd.user.services = {
      sunshine = {
        path = [ config.system.path ];
        serviceConfig.Slice = "background-graphical.slice";
        after = [ "graphical-session.target" ];
      };
    };

  };

}
