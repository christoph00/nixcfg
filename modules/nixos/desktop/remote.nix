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
  inherit (flake.lib) mkBoolOpt mkSecret;
  inherit (lib) mkIf getExe;
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

    age.secrets.self-pem = mkSecret {
      file = "self";
      owner = "christoph";
      group = "users";
    };

    services.udev.extraRules = ''
      KERNEL=="uinput", GROUP="input", MODE="0666", OPTIONS+="static_node=uinput"
    '';
    environment.systemPackages = [ switch-resolution ];
    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = false;
      openFirewall = true;
      settings = {
        vaapi_strict_rc_buffer = "enabled";
        qp = 3;
        adapter_name = "/dev/dri/renderD128";
        locale = "de";
        capture = "wlr";
        min_threads = 3;
        encoder = "vaapi";
        # global_prep_cmd = [{"do":"/run/current-system/sw/bin/switch-resolution","undo":"/run/current-system/sw/bin/switch-resolution reset"}]
        global_prep_cmd = builtins.toJSON [
          {
            do = "${switch-resolution}/bin/switch-resolution";
            undo = "${switch-resolution}/bin/switch-resolution reset";
          }
        ];
        key_rightalt_to_key_win = "enabled";
        fec_percentage = 3;
        high_resolution_scrolling = "disabled";

      };
    };

    systemd.user.services = {
      wayvnc = {
        description = "wayvnc";
        script = "${getExe pkgs.wayvnc} --gpu --log-level info --output HEADLESS-1";
        # wantedBy = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig.Slice = "background-graphical.slice";
      };
      novnc = {
        description = "novnc";
        script = "${getExe pkgs.novnc} --listen 0.0.0.0:6080 --vnc 127.0.0.1:5900 --cert ${config.age.secrets.self-pem.path}";
        # wantedBy = [ "graphical-session.target" ];
        path = [ config.system.path ];
        requires = [ "wayvnc.service" ];
        serviceConfig = {
          Slice = "background-graphical.slice";
          SuccessExitStatus = 143;
        };

      };
      sunshine = {
        path = [ config.system.path ];
        serviceConfig.Slice = "background-graphical.slice";
        after = [ "graphical-session.target" ];
      };
    };

  };

}
