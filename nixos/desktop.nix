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
  boot.loader.timeout = lib.mkForce 0;

  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  services.dbus = {
    enable = true;
    # implementation = "broker";
    # packages = [pkgs.gcr pkgs.dconf];
  };
  hardware.uinput.enable = true;

  virtualisation = {
    #   waydroid.enable = true;
    lxd.enable = true;
    podman.enable = true;
    podman.dockerSocket.enable = true;
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
  services.blueman.enable = false;

  programs.dconf.enable = true;

  services.udev.packages = with pkgs; [gnome.gnome-settings-daemon];
  services.fwupd.enable = true;

  programs.ssh.startAgent = true;

  # Greeter
  # programs.regreet.enable = true;
  services.greetd = {
    enable = true;
    restart = true;
    settings = {
      default_session = {
        command = "${pkgs.dbus}/bin/dbus-run-session ${pkgs.cage}/bin/cage -s -- ${pkgs.greetd.regreet}/bin/regreet";
        user = "greeter";
      };
      initial_session = {
        command = "Hyprland";
        user = "christoph";
      };
    };
  };
  # environment.etc."greetd/environments".text = ''
  #   Hyprland
  #   startplasma-wayland"
  # '';

  security.pam.services.greetd.gnupg.enable = true;

environment.systemPackages = with pkgs; [
    fluent-gtk-theme
    apple-cursor
    fluent-icon-theme
  ];


  programs.regreet = {
    enable = true;
     settings = {
      GTK = {
        cursor_theme_name = "macOS-Monterey";
        font_name = "Roboto 12";
        icon_theme_name = "Fluent";
        theme_name = "Fluent-Light";
      };
    };
  };

  # services.greetd = {
  #   enable = true;
  #   restart = true;
  #   settings = {
  #     default_session = {
  #       command = "${pkgs.dbus}/bin/dbus-run-session ${pkgs.cage}/bin/cage -s -- ${pkgs.greetd.regreet}/bin/regreet";
  #       user = "greeter";
  #     };
  #   };
  # };

  security = {
    rtkit.enable = true;
  };

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = ["graphical-session.target"];
    wants = ["graphical-session.target"];
    after = ["graphical-session.target"];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  #systemd.services."user@1000".serviceConfig.LimitNOFILE = "32768";

  hardware.logitech.wireless.enable = true;

  networking.firewall = {
    allowedTCPPorts = [22000 47989 47990 5901 8000];
    allowedUDPPorts = [21027 22000 47989 47990 5901];
  };
  networking.firewall.enable = true;

  networking.networkmanager.enable = lib.mkForce true;

  # programs.kdeconnect.enable = true;
  # programs.nm-applet.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # extraPortals = [
    #   pkgs.xdg-desktop-portal-gtk
    #   #  inputs.xdg-portal-hyprland.packages.${pkgs.system}.default
    # ];
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

  programs.adb.enable = true;

  environment.persistence."/nix/persist" = {
    directories = [
      "/etc/NetworkManager/system-connections"
      "/var/lib/waydroid"
      "/var/lib/lxd"
      "/var/lib/lxc"
    ];
    /*
    users.christoph = {
      directories = [
        "Downloads"
        "Music"
        "Bilder"
        "Dokumente"
        "Code"
        "Videos"
        "Desktop"
        #"Games"
        {
          directory = ".gnupg";
          mode = "0700";
        }
        {
          directory = ".ssh";
          mode = "0700";
        }
        {
          directory = ".local/share/keyrings";
          mode = "0700";
        }

        ".local/share/direnv"

        ".config/chromium/Default"
        ".config/obisdian"
        ".config/Code"
        ".config/gh"
        ".config/brew" # matcha
        ".config/libreoffice"
        ".config/GeForce\ NOW"
        ".config/easyeffects"

        ".vscode"
        ".cargo"

        ".cache/nix-index"
        ".local/share/Paradox\ Interactive"
        ".paradoxlauncher"
        ".local/share/Steam"
        "Games"
        ".config/gamescope"

        #".config/gtk-3.0" # fuse mounted to /home/$USERNAME/.config/gtk-3.0
        #".config/gtk-4.0"
        ".config/KDE"
        ".config/kde.org"
        ".config/plasma-workspace"
        ".config/kate"
        ".config/kdeconnect"
        # ".config/xsettingsd"
        ".kde"

        ".local/share/baloo"
        ".local/share/dolphin"
        ".local/share/kactivitymanagerd"
        ".local/share/kate"
        ".local/share/klipper"
        ".local/share/konsole"
        ".local/share/kscreen"
        ".local/share/kwalletd"
        ".local/share/kxmlgui5"
        ".local/share/RecentDocuments"
        ".local/share/sddm"
        ".local/share/color-schemes"
      ];
      files = [
        ".screenrc"
        ".config/akregatorrc"
        ".config/baloofileinformationrc"
        ".config/baloofilerc"
        ".config/breezerc"
        # ".config/bluedevilglobalrc"
        ".config/device_automounter_kcmrc"
        ".config/dolphinrc"
        ".config/filetypesrc"
        # #".config/gtkrc"
        # #".config/gtkrc-2.0"
        ".config/gwenviewrc"
        ".config/kactivitymanagerd-pluginsrc"
        ".config/kactivitymanagerd-statsrc"
        ".config/kactivitymanagerd-switcher"
        ".config/kactivitymanagerdrc"
        ".config/katemetainfos"
        ".config/katerc"
        ".config/kateschemarc"
        ".config/katevirc"
        ".config/kcmfonts"
        ".config/kcminputrc"
        ".config/kconf_updaterc"
        ".config/kded5rc"
        ".config/kdeglobals"
        ".config/kgammarc"
        ".config/kglobalshortcutsrc"
        # ".config/khotkeysrc"
        ".config/kmixrc"
        ".config/konsolerc"
        ".config/kscreenlockerrc"
        ".config/ksmserverrc"
        ".config/ksplashrc"
        # ".config/ktimezonedrc"
        ".config/kwinrc"
        ".config/kwinrulesrc"
        ".config/kxkbrc"
        ".config/mimeapps.list"
        # ".config/partitionmanagerrc"
        # ".config/plasma-localerc"
        # ".config/plasma-nm"
        ".config/plasma-org.kde.plasma.desktop-appletsrc"
        ".config/plasmanotifyrc"
        ".config/plasmarc"
        ".config/plasmashellrc"
        # ".config/PlasmaUserFeedback"
        ".config/plasmawindowed-appletsrc"
        ".config/plasmawindowedrc"
        ".config/powermanagementprofilesrc"
        # ".config/spectaclerc"
        ".config/startkderc"
        ".config/systemsettingsrc"
        ".config/Trolltech.conf"
        # ".config/user-dirs.dirs"
        # ".config/user-dirs.locale"

        # ".local/share/krunnerstaterc"
        # ".local/share/user-places.xbel"
        # ".local/share/user-places.xbel.bak"
        # ".local/share/user-places.xbel.tbcache"

        ".steam/steam.token"
        ".steam/registry.vdf"
      ];
    };
    */
  };
}
