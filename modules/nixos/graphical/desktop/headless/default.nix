{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib
, # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs
, # You also have access to your flake's inputs.
  inputs
, # Additional metadata is provided by Snowfall Lib.
  namespace
, # The namespace used for your flake, defaulting to "internal" if not set.
  system
, # The system architecture for this host (eg. `x86_64-linux`).
  target
, # The Snowfall Lib target for this system (eg. `x86_64-iso`).
  format
, # A normalized name for the system target (eg. `iso`).
  virtual
, # A boolean to determine whether this system is a virtual target using nixos-generators.
  systems
, # An attribute map of your defined hosts.

  # All other arguments come from the module system.
  config
, ...
}:

with builtins;
with lib;
with lib.internal;

let
  cfg = config.internal.graphical.desktop.headless;
  set_resolution = (
    pkgs.writeShellScriptBin "set_resolution" ''
      if [ -z "$SUNSHINE_CLIENT_WIDTH" ] || [ -z "$SUNSHINE_CLIENT_HEIGHT" ] || [ -z "$SUNSHINE_CLIENT_FPS" ]; then
          echo "Missing env Vars from Sunshine"
          exit 1
      fi

      MODE="''${SUNSHINE_CLIENT_WIDTH}x''${SUNSHINE_CLIENT_HEIGHT}@''${SUNSHINE_CLIENT_FPS}Hz"

      ${pkgs.wlr-randr}/bin/wlr-randr --output HEADLESS-1 --on --custom-mode $MODE

    ''
  );
in
{

  options.internal.graphical.desktop.headless = {
    enable = mkBoolOpt config.internal.isHeadlessDesktop "
      Enable
      Headless
      Desktop.";
    enableStreaming = mkBoolOpt config.internal.isGameStream "
      Enable
      Streaming ";
    autorun = mkBoolOpt true "
      Autorun ";
    user = mkOption {
      type = types.str;
      default = "
      christoph ";

    };
  };

  config = mkIf cfg.enable {

    programs.uwsm.waylandCompositors.labwc = {
      binPath =
        let
          exec-labwc = (
            pkgs.writeShellScriptBin "exec-labwc" ''
              env \
                WLR_NO_HARDWARE_CURSORS=1 \
                WLR_BACKENDS=drm,headless,libinput \
                WLR_RENDER_DRM_DEVICE=/dev/dri/renderD128 \
                ${config.programs.labwc.package}/bin/labwc
            ''
          );
        in
        lib.mkForce "${exec-labwc}/bin/exec-labwc";
    };


    boot.kernelModules = [
      "uinput "
    ];
    services.udev.extraRules = ''
      KERNEL=="
      uinput ", GROUP="
      input ", MODE=" 0660 " OPTIONS+="
      static_node= uinput "
    '';
    environment.systemPackages = [ set_resolution ];
    environment.variables = {
      WLR_BACKENDS = "
      drm,headless,libinput";
      #   #NIXOS_OZONE_WL = "1";
      #   #WAYLAND_DISPLAY = "wayland-1";
      #   #WLR_LIBINPUT_NO_DEVICES = "1";
      #   WLR_RENDERER = "pixman";
      WLR_RENDER_DRM_DEVICE = "/dev/dri/card0";
      #   AQ_DRM_DEVICES = "/dev/dri/card0";

    };

    services.seatd.enable = true;

    ## DP-2 = Monitor  HDMI-A-1 = Dummy
    # services.sunshine = {
    # enable = true;
    # autoStart = false;
    # capSysAdmin = false;
    # openFirewall = true;

    # };

    # systemd.user.services.headless-desktop = {
    #   wantedBy = optional cfg.autorun "default.target";
    #   description = "Graphical headless server";
    #   serviceConfig = {
    #     ExecStartPre = "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_RUNTIME_DIR WLR_BACKENDS;
    #     ExecStart = "${pkgs.runtimeShell} -c 'source /etc/set-environment; exec ${config.programs.wayfire.package}/bin/wayfire'";
    #   };
    # };
    # users.extraUsers."${cfg.user}"   .linger = mkDefault true;

  };

}
