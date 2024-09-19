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
  cfg = config.internal.graphical.desktop.headless;
in
{

  options.internal.graphical.desktop.headless = {
    enable = mkBoolOpt false "Enable Headless Desktop.";
    enableStreaming = mkBoolOpt config.internal.graphical.desktop.headless "Enable Streaming";
    autorun = mkBoolOpt true "Autorun";
    user = mkOption {
      type = types.str;
      default = "christoph";

    };
  };

  config = mkIf cfg.enable {

    boot.kernelModules = [ "uinput" ];
    services.udev.extraRules = ''
      KERNEL=="uinput", GROUP="input", MODE="0660" OPTIONS+="static_node=uinput"
    '';

    environment.sessionVariables = {
      WLR_BACKENDS = "drm,headless,libinput";
      NIXOS_OZONE_WL = "1";
      WAYLAND_DISPLAY = "wayland-1";
      #WLR_LIBINPUT_NO_DEVICES = "1";
      WLR_RENDERER = "pixman";
      #XDG_RUNTIME_DIR="/tmp";
      XDG_RUNTIME_DIR = "/run/user/1000";
      WLR_RENDER_DRM_DEVICE = "/dev/dri/card0";

    };
    services.xserver.autorun = false;
    services.graphical-desktop.enable = true;

    services.seatd.enable = true;

    
    ## DP-2 = Monitor  HDMI-A-1 = Dummy
    services.sunshine = mkIf cfg.enableStreaming {
      enable = true;
      autoStart = true;
      capSysAdmin = false;
      openFirewall = true;
      settings = {
        min_log_level = "info";
        capture = "wlr";
        encoder = "vaapi";
        address_family = "both";
        controller = "enabled";
        gamepad = "x360";
        adapter_name = "/dev/dri/renderD129";
       min_threads = 4;
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
              #prep-cmd = [ prep ];
              image-path = mk-icon { icon-name = "cinnamon-virtual-keyboard"; };
            }

            {
              name = "Steam Big Picture";
              cmd = "${steam} -gamepadui";
              #prep-cmd = [ prep ];
              image-path = mk-icon { icon-name = "steamlink"; };
            }
            {
              name = "Steam (Regular UI)";
              cmd = "${steam}";
              #prep-cmd = [ prep ];
              image-path = mk-icon { icon-name = "steam"; };
            }
          ];
      };
    };

     systemd.user.services.headless-desktop = {
        wantedBy = optional cfg.autorun "default.target";
        description = "Graphical headless server";
        serviceConfig = {
          ExecStartPre =  "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_RUNTIME_DIR WLR_BACKENDS; systemctl --user import-environment";
          ExecStart = "${pkgs.runtimeShell} -c 'source /etc/set-environment; exec ${config.programs.wayfire.package}/bin/wayfire'";
        };
      };
      users.extraUsers."${cfg.user}".linger = mkDefault true;


  };

}
