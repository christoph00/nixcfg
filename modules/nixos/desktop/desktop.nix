{
  config,
  flake,
  lib,
  options,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkDefault;
  inherit (flake.lib) mkBoolOpt;
  cfg = config.desktop;
in
{
  options.desktop = {
    enable = mkBoolOpt false;
    headless = mkBoolOpt false;
    waybar = mkBoolOpt true;
    wlsunset = mkBoolOpt false;
  };
  config = mkIf cfg.enable {
    hardware.graphics.enable = true;

    boot.kernelModules = [ "uinput" ];
    services.udev.extraRules = ''
      KERNEL=="uinput", GROUP="input", MODE="0660" OPTIONS+="static_node=uinput"
    '';

    environment.variables = {
      NIXOS_OZONE_WL = "1";
      _JAVA_AWT_WM_NONEREPARENTING = "1";
      GDK_BACKEND = "wayland,x11";
      MOZ_ENABLE_WAYLAND = "1";
      XDG_SESSION_TYPE = "wayland";
      SDL_VIDEODRIVER = "wayland";
      CLUTTER_BACKEND = "wayland";
    };
    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      wlr.enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
      ];
      config.common = {
        default = [
          "gtk"
          "wlr"
        ];
      };
    };

    services = {
      gvfs.enable = true;

      udisks2.enable = true;

      dbus = {
        enable = true;
        implementation = "broker";

        packages = builtins.attrValues { inherit (pkgs) dconf gcr udisks2; };
      };

      timesyncd.enable = true;
      chrony.enable = false;
    };

    programs.uwsm = {
      enable = true;
      # waylandCompositors = {
      # niri = {
      #   prettyName = "Niri";
      #   comment = "A scrollable-tiling Wayland compositor.";
      #   binPath = "${pkgs.niri}/bin/niri";
      # };
      # labwc = {
      #   prettyName = "Labwc";
      #   comment = "A Wayland window-stacking compositor.";
      #   binPath = "${pkgs.labwc}/bin/labwc";
      # };
      # };
    };

    systemd.user.services = {
      waybar = mkIf cfg.waybar {
        description = "Waybar as systemd service";
        path = [ config.system.path ];
        script = "unset __NIXOS_SET_ENVIRONMENT_DONE && . /run/current-system/etc/profile && ${pkgs.waybar}/bin/waybar";
        wantedBy = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig.Slice = "app-graphical.slice";
      };
      # sfwbar = mkIf cfg.sfwbar {
      #   description = "sfwbar";
      #   script = "unset __NIXOS_SET_ENVIRONMENT_DONE && . /run/current-system/etc/profile && ${pkgs.sfwbar}/bin/sfwbar";
      #   wantedBy = [ "graphical-session.target" ];
      #   after = [ "graphical-session.target" ];
      #   serviceConfig.Slice = "app-graphical.slice";
      #
      # };
      # ironbar = mkIf cfg.ironbar {
      #   description = "ironbar";
      #   script = "unset __NIXOS_SET_ENVIRONMENT_DONE && . /run/current-system/etc/profile && ${pkgs.ironbar}/bin/ironbar";
      #   wantedBy = [ "graphical-session.target" ];
      #   after = [ "graphical-session.target" ];
      #   serviceConfig.Slice = "app-graphical.slice";
      # };
      swww-daemon = {
        description = "swww-daemon as systemd service";
        script = "${pkgs.swww}/bin/swww-daemon";
        wantedBy = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig.Slice = "background-graphical.slice";

      };
      syshud = {
        description = "syshud";
        script = "${pkgs.syshud}/bin/syshud";
        wantedBy = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig.Slice = "background-graphical.slice";
      };

      wlsunset = mkIf cfg.wlsunset {
        description = "wlsunset";
        script = "${pkgs.wlsunset}/bin/wlsunset";
        wantedBy = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig.Slice = "background-graphical.slice";
      };

      # xsettingsd = mkIf cfg.xsettingsd {
      #   description = "xsettingsd";
      #   script = "${pkgs.xsettingsd}/bin/xsettingsd";
      #   wantedBy = [ "graphical-session.target" ];
      #   after = [ "graphical-session.target" ];
      #   serviceConfig.Slice = "background-graphical.slice";
      # };

      # xfce-power-manager = mkIf cfg.xsettingsd {
      #   description = "xfce-power-manager";
      #   script = "${pkgs.xfce.xfce4-power-manager}/bin/xfce4-power-manager";
      #   wantedBy = [ "graphical-session.target" ];
      #   after = [ "graphical-session.target" ];
      #   serviceConfig.Slice = "background-graphical.slice";
      # };
      #
      #   polkit-gnome-authentication-agent-1 = {
      #     description = "polkit-gnome-authentication-agent-1";
      #     script = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      #     wantedBy = [ "graphical-session.target" ];
      #     after = [ "graphical-session.target" ];
      #     serviceConfig.Slice = "background-graphical.slice";
      #   };
    };

    services.xserver.desktopManager.runXdgAutostartIfNone = true;

    security.pam.services.gtklock.text = lib.readFile "${pkgs.gtklock}/etc/pam.d/gtklock";
    #security.pam.services.waylock = { };

  };

}
