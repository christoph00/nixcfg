{pkgs, ...}: {
  xr6515dn = pkgs.callPackage ./xr6515dn {};
  # swww = pkgs.callPackage ./swww {};
  #wallpaper = pkgs.callPackage ./wallpaper {};
  # gfn-electron = pkgs.callPackage ./gfn-electron {};
  my-sftpgo = pkgs.callPackage ./sftpgo {};
  firefox-gnome-theme = pkgs.callPackage ./firefox-gnome-theme {};
  vscode-cli = pkgs.callPackage ./vscode-cli {};
  systemd-rest = pkgs.callPackage ./systemd-rest {};
  proton-ge = pkgs.callPackage ./proton-ge {};
  # sfwbar = pkgs.callPackage ./sfwbar {};
  # ariaNg = pkgs.callPackage ./ariaNg {};
  matcha = pkgs.callPackage ./matcha {};
  # cs-firewall-bouncer = pkgs.callPackage ./cs-firewall-bouncer {};
  media-sort = pkgs.callPackage ./media-sort {};
  # uboot-r2s = pkgs.callPackage ./uboot-r2s {};
  nextdhcp = pkgs.callPackage ./nextdhcp {};
  coredhcp = pkgs.callPackage ./coredhcp {};
  # sunshine-bin = pkgs.callPackage ./sunshine-bin {};
  # stalwart-cli = pkgs.callPackage ./stalwart-cli {};
  # stalwart-imap = pkgs.callPackage ./stalwart-imap {};
  # stalwart-jmap = pkgs.callPackage ./stalwart-jmap {};
  # stalwart-smtp = pkgs.callPackage ./stalwart-smpt {};
  vmt = pkgs.callPackage ./vmt {};
  vomit-sync = pkgs.callPackage ./vomit-sync {};
  # wl-gammarelay-rs = pkgs.callPackage ./wl-gammarelay-rs {};
  # eww-ws = pkgs.callPackage ./eww-ws {};
  # hypr-taskbar = pkgs.callPackage ./hypr-taskbar {};
  anyrun = pkgs.callPackage ./anyrun {};
  dlm = pkgs.callPackage ./dlm {};
  # systemd2mqtt = pkgs.callPackage ./systemd2mqtt {};

  wyoming-piper = pkgs.callPackage ./wyoming-piper {};

  ha-lovelace-battery-entity = pkgs.callPackage ./ha-lovelace/battery-entity.nix {};
  ha-lovelace-fold-entity-row = pkgs.callPackage ./ha-lovelace/fold-entity-row.nix {};
  ha-lovelace-mini-graph-card = pkgs.callPackage ./ha-lovelace/mini-graph-card.nix {};
  ha-lovelace-card-mod = pkgs.callPackage ./ha-lovelace/card-mod.nix {};
  ha-lovelace-better-thermostat-ui-card = pkgs.callPackage ./ha-lovelace/better-thermostat-ui-card.nix {};
  ha-lovelace-vacuum-card = pkgs.callPackage ./ha-lovelace/vacuum-card.nix {};
  ha-component-better-thermostat = pkgs.callPackage ./ha-components/better_thermostat.nix {};
  ha-component-ble-monitor = pkgs.callPackage ./ha-components/ble_monitor.nix {};
  ha-component-promql = pkgs.callPackage ./ha-components/promql.nix {};
  ha-component-zha-toolkit = pkgs.callPackage ./ha-components/zha-toolkit.nix {};

  # meli = pkgs.meli.override {
  #   cargoBuildFlags = ["--features jmap"];
  # };

  steam-with-packages = pkgs.steam.override {
    extraPkgs = pkgs:
      with pkgs; [
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
        gamescope
        gamemode
        mangohud
      ];
  };
}
