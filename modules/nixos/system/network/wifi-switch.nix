{
  options,
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.system.network;

  exclusive-lan = pkgs.writeShellScriptBin "70-wifi-wired-exclusive.sh" ''
    # From example 14:
    # https://manpages.ubuntu.com/manpages/focal/man7/nmcli-examples.7.html

    # This dispatcher script makes Wi-Fi mutually exclusive with wired networking. When a wired
    # interface is connected, Wi-Fi will be set to airplane mode (rfkilled). When the wired
    # interface is disconnected, Wi-Fi will be turned back on. Name this script e.g.
    # 70-wifi-wired-exclusive.sh and put it into /etc/NetworkManager/dispatcher.d/ directory.
    # See NetworkManager(8) manual page for more information about NetworkManager dispatcher
    # scripts.

    NMCLI=${pkgs.networkmanager}/bin/nmcli
    GREP=${pkgs.gnugrep}/bin/grep

    export LC_ALL=C

    enable_disable_wifi ()
    {
        result=$($NMCLI dev | $GREP "ethernet" | $GREP -w "connected")
        if [ -n "$result" ]; then
            $NMCLI radio wifi off
        else
            $NMCLI radio wifi on
        fi
    }

    if [ "$2" = "up" ]; then
        enable_disable_wifi
    fi

    if [ "$2" = "down" ]; then
        enable_disable_wifi
    fi
  '';
in {
  networking = mkIf cfg.wifi-switch {
    wireless.enable = false; # use network manager instead of wpa supplicanmt
    networkmanager = {
      dispatcherScripts = [
        {
          # source = ./nm-dispatcher-scripts/70-wifi-wired-exclusive.sh;
          source = "${exclusive-lan}/bin/70-wifi-wired-exclusive.sh";
        }
      ];
    };
  };
}
