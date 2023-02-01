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
  boot.plymouth.enable = true;

  time.timeZone = "Europe/Berlin";

  services.dbus = {
    enable = true;
    implementation = "broker";
    packages = [pkgs.gcr pkgs.dconf];
  };
  hardware.uinput.enable = true;

  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = false;

  programs.dconf.enable = true;

  services.udev.packages = with pkgs; [gnome.gnome-settings-daemon];
  services.fwupd.enable = true;

  programs.ssh.startAgent = true;

  security = {
    rtkit.enable = true;
    pam.services = {
      sddm.u2fAuth = false;
      sddm.enableKwallet = true;
    };

    pam.loginLimits = [
      {
        domain = "*";
        item = "memlock";
        type = "-";
        value = "unlimited";
      }
      {
        domain = "*";
        item = "nofile";
        type = "soft";
        value = "unlimited";
      }
      {
        domain = "*";
        item = "nofile";
        type = "hard";
        value = "unlimited";
      }
    ];
  };

  #systemd.services."user@1000".serviceConfig.LimitNOFILE = "32768";

  networking.firewall = {
    allowedTCPPorts = [22000 47989 47990 5901];
    allowedUDPPorts = [21027 22000 47989 47990 5901];
  };
  networking.firewall.enable = false;

  programs.kdeconnect.enable = true;

  programs.steam.enable = true;
  programs.gamemode = {
    enable = true;
    settings = {
      custom = {
        start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
        end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
      };
    };
  };
  programs.steam.package = pkgs.steam-with-packages;
  systemd.extraConfig = "DefaultLimitNOFILE=1048576";

  systemd.user.services.x11-ownership = rec {
    serviceConfig.Type = "oneshot";
    script = ''
      sudo chown christoph /tmp/.X11-unix
    '';
    after = ["graphical-session.target"];
    wants = after;
    wantedBy = ["graphical-session-pre.target"];
  };

  # autologin-graphical-session = {
  #   enable = true;
  #   user = "christoph";
  #   sessionScript = "Hyprland";
  # };

  xdg.portal = {
    enable = true;
    # wlr.enable = true;
    # extraPortals = [
    #   pkgs.xdg-desktop-portal-gtk
    #   #  inputs.xdg-portal-hyprland.packages.${pkgs.system}.default
    # ];
  };

  programs.hyprland = {
    enable = false;
    package = null; # Managed by home manager
    xwayland.enable = true;
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
