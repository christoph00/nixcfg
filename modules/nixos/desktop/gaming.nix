{
  lib,
  flake,
  pkgs,
  options,
  config,
  perSystem,
  ...
}:
let
  inherit (lib) mkIf mkPackageOption;
  inherit (flake.lib) mkBoolOpt enabled;
  cfg = config.desktop.gaming;
  up = perSystem.nixpkgs-unstable;
in
{
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
          general = { renice = 10; };
          custom = {
            start = "${up.libnotify}/bin/notify-send 'GameMode started'";
            end = "${up.libnotify}/bin/notify-send 'GameMode ended'";
          };
        };
      };
    };

    environment.systemPackages =
      with up;
      let
        protonhax = writeShellScriptBin "protonhax" ''
          phd=''${XDG_RUNTIME_DIR:-/run/user/$UID}/protonhax
          usage() {
              echo "Usage:"
              echo "protonhax init <cmd>"
              printf "\tShould only be called by Steam with \"protonhax init %%COMMAND%%\"\n"
              echo "protonhax ls"
              printf "\tLists all currently running games\n"
              echo "protonhax run <appid> <cmd>"
              printf "\tRuns <cmd> in the context of <appid> with proton\n"
              echo "protonhax cmd <appid>"
              printf "\tRuns cmd.exe in the context of <appid>\n"
              echo "protonhax exec <appid> <cmd>"
              printf "\tRuns <cmd> in the context of <appid>\n"
          }
          if [[ $# -lt 1 ]]; then usage; exit 1; fi
          c=$1; shift
          if [[ "$c" == "init" ]]; then
              mkdir -p $phd/$SteamAppId
              printf "%s\n" "''${@}" | grep -m 1 "/proton" > $phd/$SteamAppId/exe
              printf "%s" "$STEAM_COMPAT_DATA_PATH/pfx" > $phd/$SteamAppId/pfx
              declare -px > $phd/$SteamAppId/env
              "$@"; ec=$?; rm -r $phd/$SteamAppId; exit $ec
          elif [[ "$c" == "ls" ]]; then
              if [[ -d $phd ]]; then ls -1 $phd; fi
          elif [[ "$c" == "run" ]] || [[ "$c" == "cmd" ]] || [[ "$c" == "exec" ]]; then
              if [[ $# -lt 1 ]]; then usage; exit 1; fi
              if [[ ! -d $phd/$1 ]]; then printf "No app running with appid \"%s\"\n" "$1"; exit 2; fi
              SteamAppId=$1; shift
              if [[ ! -f "$phd/$SteamAppId/env" ]]; then
                notify-send "ProtonHax Error" "No environment file found for AppID $SteamAppId." --urgency=critical
                exit 2
              fi
              source $phd/$SteamAppId/env
              if [[ "$c" == "run" ]]; then exec "$(cat $phd/$SteamAppId/exe)" run "$@"; fi
              if [[ "$c" == "cmd" ]]; then exec "$(cat $phd/$SteamAppId/exe)" run "$(cat $phd/$SteamAppId/pfx)/drive_c/windows/system32/cmd.exe"; fi
              if [[ "$c" == "exec" ]]; then exec "$@"; fi
          else printf "Unknown command %s\n" "$c"; usage; exit 1; fi
        '';
      in
      [
        steam
        protonplus
        protontricks
        gamemode
        protonhax
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
      ];
  };
}
