{
  lib,
  flake,
  pkgs,
  options,
  config,
  ...
}:
let
  inherit (lib) mkIf mkPackageOption;
  inherit (flake.lib) mkBoolOpt enabled;
  cfg = config.desktop.gaming;
in
{
  options.desktop.gaming = {
    enable = mkBoolOpt false;
    proton = mkPackageOption pkgs "proton-ge-bin" { };
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
      # PROTON_USE_NTSYNC = "1";
      # PROTON_ENABLE_AMD_AGS = "1";
      # STEAM_MULTIPLE_XWAYLANDS = "1";
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
        # wantedBy = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        script = "${config.programs.steam.package}/bin/steam -pipewire-dmabuf -silent";
      };
    };

    services.input-remapper = enabled;

    programs = {
      steam = {
        enable = true;
        package = pkgs.steam.override {
          extraLibraries =
            pkgs: with pkgs; [
              xz
              openssl
              xorg.libXcursor
              xorg.libXi
              xorg.libXinerama
              xorg.libXScrnSaver
              libpng
              libpulseaudio
              libvorbis
              stdenv.cc.cc.lib
              libkrb5
              keyutils
            ];
        };
        extraCompatPackages = with pkgs; [
          proton-ge-bin
          steamtinkerlaunch
          cfg.proton
        ];
        gamescopeSession = enabled;
        protontricks = enabled;
        extest = enabled; # controller input
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
            start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
            end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
          };
        };
      };

    };

    programs.uwsm = {
      # waylandCompositors = {
      # steam-gamescope = {
      #   prettyName = "Steam";
      #   comment = "Steam Gamescope Session managed by UWSM";
      #   binPath = "/run/current-system/sw/bin/steam-gamescope";
      # };
      # };
    };

    environment.systemPackages =
      with pkgs;
      let
        protonhax = writeShellScriptBin "protonhax" ''
          phd=''${XDG_RUNTIME_DIR:-/run/user/$UID}/protonhax
          # Function to print usage
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

          # Function to check if a variable points to a valid path

          # If arguments are missing, show usage
          if [[ $# -lt 1 ]]; then
              usage
              exit 1
          fi

          c=$1
          shift

          if [[ "$c" == "init" ]]; then
              mkdir -p $phd/$SteamAppId
              printf "%s\n" "''${@}" | grep -m 1 "/proton" > $phd/$SteamAppId/exe
              printf "%s" "$STEAM_COMPAT_DATA_PATH/pfx" > $phd/$SteamAppId/pfx
              declare -px > $phd/$SteamAppId/env
              "$@"
              ec=$?
              rm -r $phd/$SteamAppId
              exit $ec
          elif [[ "$c" == "ls" ]]; then
              if [[ -d $phd ]]; then
                  ls -1 $phd
              fi
          elif [[ "$c" == "run" ]] || [[ "$c" == "cmd" ]] || [[ "$c" == "exec" ]]; then
              if [[ $# -lt 1 ]]; then
                  usage
                  exit 1
              fi
              if [[ ! -d $phd ]]; then
                  printf "No app running with appid \"%s\"\n" "$1"
                  exit 2
              fi
              if [[ ! -d $phd/$1 ]]; then
                  printf "No app running with appid \"%s\"\n" "$1"
                  exit 2
              fi
              SteamAppId=$1
              shift

              if [[ ! -f "$phd/$SteamAppId/env" ]]; then
                notify-send "ProtonHax Error" "No environment file found for AppID $SteamAppId." --urgency=critical
                exit 2
              fi

              source $phd/$SteamAppId/env

              if [[ "$c" == "run" ]]; then
                  if [[ $# -lt 1 ]]; then
                      usage
                      exit 1
                  fi
                  exec "$(cat $phd/$SteamAppId/exe)" run "$@"
              elif [[ "$c" == "cmd" ]]; then
                  exec "$(cat $phd/$SteamAppId/exe)" run "$(cat $phd/$SteamAppId/pfx)/drive_c/windows/system32/cmd.exe"
              elif [[ "$c" == "exec" ]]; then
                  if [[ $# -lt 1 ]]; then
                      usage
                      exit 1
                  fi
                  exec "$@"
              fi
          else
              printf "Unknown command %s\n" "$c"
              usage
              exit 1
          fi
        '';
      in
      [
        steam
        protonplus
        protontricks
        gamemode
#       openmw
#        bottles
#        limo
        # veloren
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
