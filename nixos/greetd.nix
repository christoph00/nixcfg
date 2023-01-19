{
  config,
  pkgs,
  lib,
  ...
}: let
  sway-kiosk = command: "${pkgs.sway}/bin/sway --config ${pkgs.writeText "kiosk.config" ''
    output * bg #000000 solid_color
    exec dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK
    exec "${command}; ${pkgs.sway}/bin/swaymsg exit"
  ''}";
in {
  services.greetd = {
    enable = true;
    settings = {
      default_session.command = let
        gtkgreetStyle = pkgs.writeText "greetd-gtkgreet.css" ''
          window {
            background-position: center;
            background-repeat: no-repeat;
            background-size: cover;
            background-color: black;
          }
          #body > box > box > label {
            text-shadow: 0 0 3px #1e1e2e;
            color: #f5e0dc;
          }
          entry {
            color: #f5e0dc;
            background: rgba(30, 30, 46, 0.8);
            border-radius: 16px;
            box-shadow: 0 0 5px #1e1e2e;
          }
          #clock {
            color: #f5e0dc;
            text-shadow: 0 0 3px #1e1e2e;
          }
          .text-button { border-radius: 16px; }
        '';
        #in "${pkgs.dbus}/bin/dbus-run-session ${pkgs.cage}/bin/cage -s -- ${pkgs.greetd.gtkgreet} -l -s ${gtkgreetStyle}";
        #in "${pkgs.cage}/bin/cage -s ${pkgs.greetd.gtkgreet}/bin/gtkgreet -- -l -s ${gtkgreetStyle}";
      in
        sway-kiosk "${pkgs.greetd.gtkgreet}/bin/gtkgreet -l &>/dev/null -s ${gtkgreetStyle} -l";
      #initial_session = {
      #  command = "Hyprland";
      #  user = "christoph";
      #};
    };
  };

  environment.etc."greetd/environments".text = ''
    Hyprland
    fish
    startxfce4
  '';
}
