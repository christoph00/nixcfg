{pkgs, ...}: {
  xr6515dn = pkgs.callPackage ./xr6515dn {};
  swww = pkgs.callPackage ./swww {};
  #wallpaper = pkgs.callPackage ./wallpaper {};
  gfn-electron = pkgs.callPackage ./gfn-electron {};
  my-sftpgo = pkgs.callPackage ./sftpgo {};
  firefox-gnome-theme = pkgs.callPackage ./firefox-gnome-theme {};
  vscode-cli = pkgs.callPackage ./vscode-cli {};
  systemd-rest = pkgs.callPackage ./systemd-rest {};
  proton-ge = pkgs.callPackage ./proton-ge {};
  sfwbar = pkgs.callPackage ./sfwbar {};
  ariaNg = pkgs.callPackage ./ariaNg {};
  matcha = pkgs.callPackage ./matcha {};
  wails-beta = pkgs.callPackage ./wails-beta {};

  ha-lovelace-battery-entity = pkgs.callPackage ./ha-lovelace/battery-entity.nix {};
  ha-lovelace-fold-entity-row = pkgs.callPackage ./ha-lovelace/fold-entity-row.nix {};
  ha-lovelace-mini-graph-card = pkgs.callPackage ./ha-lovelace/mini-graph-card.nix {};
  ha-lovelace-card-mod = pkgs.callPackage ./ha-lovelace/card-mod.nix {};
  ha-lovelace-better-thermostat-ui-card = pkgs.callPackage ./ha-lovelace/better-thermostat-ui-card.nix {};
  ha-lovelace-vacuum-card = pkgs.callPackage ./ha-lovelace/vacuum-card.nix {};
  ha-components-better-thermostat = pkgs.callPackage ./ha-components/better_thermostat.nix {};
  ha-components-ble-monitor = pkgs.callPackage ./ha-components/ble_monitor.nix {};

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
      ];
  };

  sftpgo = pkgs.sftpgo.overrideAttrs (old: {
    tags = ["nopgxregisterdefaulttypes" "bundle" "nosqlite"];
    preBuildPhases = ["cpBundle"];
    cpBundle = "cp -r {openapi,static,templates} internal/bundle/";
  });
}
