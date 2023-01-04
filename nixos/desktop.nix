{
  config,
  lib,
  pkgs,
  system,
  ...
}: {
  # Disable mitigations on desktop
  boot.kernelParams = [
    "l1tf=off"
    "mds=off"
    "mitigations=off"
    "no_stf_barrier"
    "noibpb"
    "noibrs"
    "nopti"
    "nospec_store_bypass_disable"
    "nospectre_v1"
    "nospectre_v2"
    "tsx=on"
    "tsx_async_abort=off"
  ];

  time.timeZone = "Europe/Berlin";

  services.dbus = {
    enable = true;
    implementation = "broker";
    packages = [pkgs.gcr pkgs.dconf];
  };

  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  programs.dconf.enable = true;

  services.udev.packages = with pkgs; [gnome.gnome-settings-daemon];
  services.fwupd.enable = true;

  security = {
    rtkit.enable = true;
    pam.services = {
      sddm.u2fAuth = false;
      sddm.enableGnomeKeyring = true;
      gtklock.text = "auth include login";
    };
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      #  inputs.xdg-portal-hyprland.packages.${pkgs.system}.default
    ];
  };

  programs.hyprland = {
    enable = true;
    package = null; # Managed by home manager
  };

  services.geoclue2.enable = true;
}
