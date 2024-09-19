{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib,
  # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs,
  # You also have access to your flake's inputs.
  inputs,

  # Additional metadata is provided by Snowfall Lib.
  namespace, # The namespace used for your flake, defaulting to "internal" if not set.
  system, # The system architecture for this host (eg. `x86_64-linux`).
  target, # The Snowfall Lib target for this system (eg. `x86_64-iso`).
  format, # A normalized name for the system target (eg. `iso`).
  virtual, # A boolean to determine whether this system is a virtual target using nixos-generators.
  systems, # An attribute map of your defined hosts.

  # All other arguments come from the module system.
  config,

  ...
}:

with builtins;
with lib;
with lib.internal;

let
  cfg = config.internal.graphical.desktop.display-manager;
in
{

  options.internal.graphical.desktop.display-manager = {
    enable = mkBoolOpt config.internal.isGraphical "Enable the Display Manager.";
  };

  config = mkIf cfg.enable {
    services.xserver.displayManager.startx.enable = true;

      services.greetd = {
    enable = true;
    settings = {
      default_session.command = let
        gtkgreetStyle = pkgs.writeText "greetd-gtkgreet.css" ''
          window {
            background-image: url("${wall}");
            background-position: center;
            background-repeat: no-repeat;
            background-size: cover;
            background-color: black;
          }
          box#body {
            background-color: #${colors.base00};
            border-radius: 10px;
            padding: 50px;
            border-style: solid;
            border-color: #${colors.base08};
            border-width: 3px;
          }
          * { color: #${colors.base05}; border-style: none; font-family: "JetBrainsMono Nerd Font"; }
          #clock { color: #${colors.base00}; }
          entry { background: #${colors.base00}; border-style: none; }
          entry:hover, entry:focus { background: #${colors.base00}; box-shadow: none; }
          button { background: #${colors.base00}; border-style: none; }
          button:hover { background: #${colors.base08}; }
          button * { color: #${colors.base08}; }
          button:hover * { color: #${colors.base00}; }
          menu { background: #${colors.base01}; border-radius: 0px; }
          menu *:hover { background: #${colors.base02}; }
          button { box-shadow: none; text-shadow: none; }
          button.combo:hover { border-bottom-left-radius: 5px; border-top-left-radius: 5px; }
        ''; in 
        "${pkgs.cage}/bin/cage -s  -- ${pkgs.greetd.gtkgreet}/bin/gtkgreet -l -s ${gtkgreetStyle}";
        initial_session = {
          command = "wayfire >/dev/null";
          user = "christoph";
        };
    };
  };

  environment.etc."greetd/environments".text = ''
    wayfire >/dev/null
    cosmic-session >/dev/null
    bash
  '';

  };

}
