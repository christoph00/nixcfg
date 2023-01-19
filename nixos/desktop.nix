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

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

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

  services.mingetty.autologinUser = "christoph";

  environment.loginShellInit = ''
    [[ "$(tty)" == /dev/tty? ]] && ${pkgs.vlock}/bin/vlock -c
    [[ "$(tty)" == /dev/tty1 ]] && Hyprland
  '';

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

  # Udev Rules
  services.udev.extraRules = ''

    # Stadia Controller
    # SDP protocol
    KERNEL=="hidraw*", ATTRS{idVendor}=="1fc9", MODE="0666"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="1fc9", MODE="0666"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0d28", MODE="0666"
    # Flashloader
    KERNEL=="hidraw*", ATTRS{idVendor}=="15a2", MODE="0666"
    # Controller
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="18d1", MODE="0666"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="18d1", ATTRS{idProduct}=="9400", MODE="0660", TAG+="uaccess"
  '';

  services.geoclue2.enable = true;
}
