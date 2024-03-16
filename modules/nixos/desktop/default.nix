{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.desktop;
  plasma = pkgs.writeScriptBin "plasma" ''
    ${pkgs.plasma-workspace}/bin/startplasma-wayland &> /dev/null
  '';
in {
  options.chr.desktop = with types; {
    enable = mkOption {
      type = types.bool;
      default = builtins.elem config.chr.type ["desktop" "laptop"];
    };
    wm = mkOption {
      type = types.enum ["Hyprland" "plasma" "wayfire"];
      default = "plasma";
    };
    autologin = mkOption {
      type = types.bool;
      default = true;
    };
    bar = mkOption {
      type = types.enum ["waybar" "eww" "ags" "ironbar" "none"];
      default = "waybar";
    };
  };

  config = mkIf cfg.enable {
    chr.desktop.hyprland.enable = true;
    # TODO enable multiple WMs + split greeter/general wayland settings

    # Disable mitigations on desktop
    boot.kernelParams = [
      "splash"
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

    boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

    hardware.opengl = {
      enable = true;
      driSupport = true;
    };

    services.logind = {
      killUserProcesses = true;
      lidSwitch = "hybrid-sleep";
      lidSwitchExternalPower = "hybrid-sleep";
      extraConfig = ''
        # IdleAction=lock
        # IdleActionSec=30
        HandlePowerKey=suspend
      '';
    };

    fonts = {
      packages = with pkgs; [
        material-symbols
        lexend
        noto-fonts
        noto-fonts-emoji
        roboto
        (nerdfonts.override {fonts = ["FiraCode" "JetBrainsMono" "Iosevka"];})
      ];
      fontconfig.defaultFonts = {
        serif = ["Roboto Serif" "Noto Color Emoji"];
        sansSerif = ["Roboto" "Noto Color Emoji"];
        monospace = ["JetBrainsMono Nerd Font" "Noto Color Emoji"];
        emoji = ["Noto Color Emoji"];
      };
    };

    hardware.logitech.wireless.enable = true;
    networking.networkmanager.enable = lib.mkForce true;

    programs.dconf.enable = true;

    services.fwupd.enable = true;

    services = {
      upower.enable = true;
    };

    # systemd.services = {
    #   seatd = {
    #     enable = true;
    #     description = "Seat management daemon";
    #     script = "${pkgs.seatd}/bin/seatd -g wheel";
    #     serviceConfig = {
    #       Type = "simple";
    #       Restart = "always";
    #       RestartSec = "1";
    #     };
    #     wantedBy = ["multi-user.target"];
    #   };
    # };

    programs.xwayland.enable = true;

    hardware.uinput.enable = true;

    environment.systemPackages = [
      pkgs.seatd
      pkgs.ddcutil
      pkgs.ddcui
      pkgs.nixd
      pkgs.grimblast
      pkgs.wl-clipboard
      pkgs.waylock
    ];
    services.udev.packages = [
      pkgs.light
      pkgs.android-udev-rules
    ];
    security.polkit.enable = true;

    services.dbus = {
      enable = true;
      # implementation = "broker";
      packages = [pkgs.gcr pkgs.dconf];
    };

    services.xserver.xkb = {
      layout = "us-german-umlaut,us";
      extraLayouts.us-german-umlaut = {
        description = "US Layout with German Umlauts";
        languages = ["eng" "ger"];
        symbolsFile = pkgs.writeText "us-german-umlaut" ''
          default partial alphanumeric_keys
          xkb_symbols "basic" {
            include "us(altgr-intl)"
            name[Group1] = "English (US, international with German umlaut)";
            key <AD03> { [ e, E, EuroSign, cent ] };
            key <AD07> { [ u, U, udiaeresis, Udiaeresis ] };
            key <AD09> { [ o, O, odiaeresis, Odiaeresis ] };
            key <AC01> { [ a, A, adiaeresis, Adiaeresis ] };
            key <AC02> { [ s, S, ssharp ] };
          };
        '';
      };
    };
  };
}
