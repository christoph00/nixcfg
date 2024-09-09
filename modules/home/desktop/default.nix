{
  options,
  config,
  lib,
  pkgs,
  namespace,
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
    ;
  inherit (lib.internal) mkBoolOpt;
  cfg = config.profiles.internal.desktop;
in
{
  options.profiles.internal.desktop = with types; {
    enable = mkBoolOpt false "Enable Desktop Options";
  };

  config = mkIf cfg.enable {
    fonts.fontconfig.enable = true;


    systemd.user.services.wayvnc = {
      Unit = {
        Description = "VNC Server";
        # Allow it to restart infinitely
        StartLimitIntervalSec = 0;
      };

      Service = {
        ExecStart = "${pkgs.writeShellScript "wayvnc-start" ''
          if [[ $XDG_SESSION_TYPE = "wayland" ]]; then
            ${lib.getExe pkgs.wayvnc} && exit 1
          else
            exit 0
          fi
        ''}";
        Restart = "on-failure";
        RestartSec = "1m";
      };

      Install = { WantedBy = [ "graphical-session.target" ]; };
    };

    # As we don't open the firewall, it should only be accessible over Tailscale
    xdg.configFile."wayvnc/config".text = ''
      address=0.0.0.0
    '';
  };

}
