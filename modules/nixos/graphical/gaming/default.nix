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
  cfg = config.internal.graphical.gaming;
  username = "christoph";
in
{

  options.internal.graphical.gaming = {
    enable = mkBoolOpt config.internal.isDesktop "Enable the Gaming.";
    enableStreaming = mkBoolOpt cfg.enable "Enable Game Streaming Host.";
  };

  config = mkIf cfg.enable {
    chaotic.steam.extraCompatPackages = with pkgs; [
      proton-ge-custom
    ];

    environment.systemPackages = [
      pkgs.heroic
    ];

    programs.steam = {
      enable = true;
    };

    wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraSessionCommands = ''
      # https://github.com/flameshot-org/flameshot/blob/master/docs/Sway%20and%20wlroots%20support.md#basic-steps
      export SDL_VIDEODRIVER=wayland
      export _JAVA_AWT_WM_NONREPARENTING=1
      export QT_QPA_PLATFORM=wayland
      export XDG_SESSION_DESKTOP=sway
      # TODO export XDG_SESSION_DESKTOP="''${XDG_SESSION_DESKTOP:-sway}"
    '';
    extraConfig = ''
      exec systemctl --user import-environment DISPLAY WAYLAND_DISPLAY SWAYSOCK
      exec hash dbus-update-activation-environment 2>/dev/null && \
        dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK

      # create virtual output on boot for sunshine host
      exec swaymsg create_output HEADLESS-1
      exec swaymsg output HEADLESS-1 resolution 1920x1080

      exec ${pkgs.sunshine}/bin/sunshine

      exec ${getExe pkgs.bash} -c "while true; do ${getExe pkgs.gamescope} -f -W 1920 -H 1080 -r 60 -- ${getExe inputs.jovian.legacyPackages.${pkgs.system}.gamescope-session}; done"

    '';
    config = {
      modifier = "Mod4";
      menu = "wofi --show run";
      bars = [
        {
          command = "waybar";
        }
      ];
      output.Headless-1 = {
        mode = "1920x1080";
        pos = "0 0";
      };
      keybindings = let
        modifier = "Alt";
      in
        lib.mkOptionDefault {
          # Desktop Utilities
          "${modifier}+c" = "exec ${pkgs.clipman}/bin/clipman pick -t wofi";
          #"${modifier}+Shift+s" = "exec ${pkgs.sway-contrib.grimshot}/bin/grimshot copy area";
          "${modifier}+Shift+s" = "exec ${pkgs.flameshot}/bin/flameshot gui";

          # Main app shortcuts
          "${modifier}+Shift+w" = "exec ${pkgs.zen-browser}/bin/zen-browser";
          "${modifier}+Shift+v" = "exec ${pkgs.pavucontrol}/bin/pavucontrol";
        };
    };
  };
    ## DP-2 = Monitor  HDMI-A-1 = Dummy
    services.sunshine = mkIf cfg.enableStreaming {
      enable = true;
      autoStart = false;
      capSysAdmin = true;
      openFirewall = true;
      settings = {
        min_log_level = "info";
        capture = "wlr";
        encoder = "vaapi";
        address_family = "both";
        controller = "enabled";
        gamepad = "x360";
      };
      applications = {

        env = {
          PATH = "/run/current-system/sw/bin:/run/wrappers/bin:/home/${username}/.nix-profile/bin:/etc/profiles/per-user/${username}/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin";
        };

        apps =
          let
            steam = lib.getExe config.programs.steam.package + " --";
            prep = {
              do = pkgs.writeScript "set-wlr-res" ''
                #!/bin/sh
                ${pkgs.wlr-randr}/bin/wlr-randr --output HDMI-A-1 --off --output HEADLESS-1 --custom-mode ''${SUNSHINE_CLIENT_WIDTH}x''${SUNSHINE_CLIENT_HEIGHT}@''${SUNSHINE_CLIENT_FPS}
              '';
              undo = ''${pkgs.bash}/bin/bash -c "${pkgs.wlr-randr}/bin/wlr-randr --output HDMI-A-1 --off --output HEADLESS-1 --custom-mode 1920x1080@60"'';
            };
            mk-icon =
              { icon-name }:
              pkgs.runCommand "${icon-name}-scaled.png" { }
                ''${pkgs.imagemagick}/bin/convert -density 1200 -resize 500x -background none ${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark/128x128/apps/${icon-name}.svg -gravity center -extent 600x800 $out'';
            download-image =
              {
                url,
                hash,
              }:
              let
                image = pkgs.fetchurl { inherit url hash; };
              in
              pkgs.runCommand "${lib.nameFromURL url "."}.png" { }
                ''${pkgs.imagemagick}/bin/convert ${image} -background none -gravity center -extent 600x800 $out'';
          in
          [
            {
              name = "Desktop";
              prep-cmd = [ prep ];
              image-path = mk-icon { icon-name = "cinnamon-virtual-keyboard"; };
            }

            {
              name = "Steam Big Picture";
              cmd = "${steam} -gamepadui";
              prep-cmd = [ prep ];
              image-path = mk-icon { icon-name = "steamlink"; };
            }
            {
              name = "Steam (Regular UI)";
              cmd = "${steam}";
              prep-cmd = [ prep ];
              image-path = mk-icon { icon-name = "steam"; };
            }
          ];
      };
    };

  };

}
