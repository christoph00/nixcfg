{
  lib,
  flake,
  pkgs,
  options,
  config,
  perSystem,
  inputs,
  ...
}:
let
  inherit (lib) mkIf mkPackageOption;
  inherit (flake.lib) mkBoolOpt enabled;
  cfg = config.desktop.gaming;
  up = perSystem.nixpkgs-unstable;
in
{
  imports = [ inputs.lsfg-vk-flake.nixosModules.default ];
  options.desktop.gaming = {
    enable = mkBoolOpt false;
    proton = mkPackageOption up "proton-ge-bin" { };
  };
  config = mkIf cfg.enable {

    boot.kernelModules = [ "ntsync" ];

    boot.kernel.sysctl = {
      "kernel.split_lock_mitigate" = 0;
      "kernel.nmi_watchdog" = 0;
      "kernel.sched_bore" = "1";
    };

    services.udev.extraRules = ''
      KERNEL=="ntsync", MODE="0644"
    '';

    environment.sessionVariables = {
      XKB_DEFAULT_LAYOUT = "de";
    };

    systemd.user.services = {
      gamemoded = {
        serviceConfig.Slice = "background-graphical.slice";
        wantedBy = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
      };
      steam = {
        serviceConfig.Slice = "app-graphical.slice";
        after = [ "graphical-session.target" ];
        script = "${config.programs.steam.package}/bin/steam -pipewire-dmabuf -silent";
      };
    };

    services.input-remapper = enabled;

    services.lsfg-vk = {
      enable = true;
      ui.enable = true; # installs gui for configuring lsfg-vk
    };

    programs = {
      steam = {
        enable = true;
        package = up.steam.override {
          extraLibraries =
            pkgs: with pkgs; [
              xz
              openssl
              libpng
              libpulseaudio
              libvorbis
              stdenv.cc.cc.lib
              libkrb5
              keyutils
            ];
        };
        extraCompatPackages = with up; [
          proton-ge-bin
          steamtinkerlaunch
          cfg.proton
        ];
        gamescopeSession = enabled;
      };
      gamescope = {
        enable = true;
        capSysNice = false;
        args = [
          "--rt"
          "--expose-wayland"
          "--backend"
          "headless"
          "-e"
          "--force-grab-cursor"
          "-f"
        ];
      };

      gamemode = {
        enable = true;
        enableRenice = true;
        settings = {
          general = {
            renice = 10;
          };
          custom = {
            start = "${up.libnotify}/bin/notify-send 'GameMode started'";
            end = "${up.libnotify}/bin/notify-send 'GameMode ended'";
          };
        };
      };
    };

    environment.systemPackages = with up; [
      steam
      protonplus
      protontricks
      gamemode
      umu-launcher
      faugus-launcher
      cacert
      dos2unix
      samba
      wine
      winetricks
      unzip
      xlsfonts
      zip
      vulkan-tools

      openmw
      openttd
      opengothic
    ];
  };
}
