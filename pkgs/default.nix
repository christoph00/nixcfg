final: prev: {
  pythonPackagesOverlays =
    (prev.pythonPackagesOverlays or [])
    ++ [
      (python-final: python-prev: {
        #wyoming = python-final.callPackage ./python/wyoming.nix {};
        #wyoming-piper = python-final.callPackage ./python/wyoming-piper.nix {};
        #androidtvremote2 = python-final.callPackage ./python/androidtvremote2.nix {};
        #faster-whisper = python-final.callPackage ./python/faster-whisper.nix {};

        androidtv = python-prev.androidtv.overrideAttrs (o: {
          patches =
            (o.patches or [])
            ++ [
              ./patches/python-androidtv-01-add-magentatv-one.patch
              ./patches/python-androidtv-02-add-magentatv-one.patch
            ];
        });
      })
    ];
  python3 = let
    self = prev.python3.override {
      inherit self;
      packageOverrides = prev.lib.composeManyExtensions final.pythonPackagesOverlays;
    };
  in
    self;

  python3Packages = final.python3.pkgs;

  xr6515dn = final.callPackage ./xr6515dn {};
  home-gallery = final.callPackage ./home-gallery {};
  neonmodem = final.callPackage ./neonmodem {};
  # swww = pkgs.callPackage ./swww {};
  #wallpaper = pkgs.callPackage ./wallpaper {};
  # gfn-electron = pkgs.callPackage ./gfn-electron {};
  my-sftpgo = final.callPackage ./sftpgo {};
  firefox-gnome-theme = final.callPackage ./firefox-gnome-theme {};
  vscode-cli = final.callPackage ./vscode-cli {};
  systemd-rest = final.callPackage ./systemd-rest {};
  proton-ge = final.callPackage ./proton-ge {};
  # sfwbar = pkgs.callPackage ./sfwbar {};
  # ariaNg = pkgs.callPackage ./ariaNg {};
  matcha = final.callPackage ./matcha {};
  ebusd = final.callPackage ./ebusd {};

  # cs-firewall-bouncer = pkgs.callPackage ./cs-firewall-bouncer {};
  media-sort = final.callPackage ./media-sort {};
  # uboot-r2s = pkgs.callPackage ./uboot-r2s {};
  nextdhcp = final.callPackage ./nextdhcp {};
  coredhcp = final.callPackage ./coredhcp {};
  # sunshine-bin = pkgs.callPackage ./sunshine-bin {};
  # stalwart-cli = pkgs.callPackage ./stalwart-cli {};
  # stalwart-imap = pkgs.callPackage ./stalwart-imap {};
  # stalwart-jmap = pkgs.callPackage ./stalwart-jmap {};
  # stalwart-smtp = pkgs.callPackage ./stalwart-smpt {};
  vmt = final.callPackage ./vmt {};
  vomit-sync = final.callPackage ./vomit-sync {};
  # wl-gammarelay-rs = pkgs.callPackage ./wl-gammarelay-rs {};
  # eww-ws = pkgs.callPackage ./eww-ws {};
  # hypr-taskbar = pkgs.callPackage ./hypr-taskbar {};
  anyrun = final.callPackage ./anyrun {};
  dlm = final.callPackage ./dlm {};
  # systemd2mqtt = pkgs.callPackage ./systemd2mqtt {};
  piper-bin = final.callPackage ./piper-bin {};

  go-vod = final.callPackage ./go-vod {};

  immich-server = final.callPackage ./immich-server {};

  photoview-api = final.callPackage ./photoview-api {};

  pigallery2 = final.callPackage ./pigallery2 {};

  ha-lovelace-battery-entity = final.callPackage ./ha-lovelace/battery-entity.nix {};
  ha-lovelace-fold-entity-row = final.callPackage ./ha-lovelace/fold-entity-row.nix {};
  ha-lovelace-mini-graph-card = final.callPackage ./ha-lovelace/mini-graph-card.nix {};
  ha-lovelace-card-mod = final.callPackage ./ha-lovelace/card-mod.nix {};
  ha-lovelace-better-thermostat-ui-card = final.callPackage ./ha-lovelace/better-thermostat-ui-card.nix {};
  ha-lovelace-vacuum-card = final.callPackage ./ha-lovelace/vacuum-card.nix {};
  ha-lovelace-mushroom = final.callPackage ./ha-lovelace/mushroom.nix {};
  ha-lovelace-button-card = final.callPackage ./ha-lovelace/button-card.nix {};
  ha-lovelace-layout-card = final.callPackage ./ha-lovelace/layout-card.nix {};

  ha-component-better-thermostat = final.callPackage ./ha-components/better_thermostat.nix {};
  ha-component-ble-monitor = final.callPackage ./ha-components/ble_monitor.nix {};
  ha-component-promql = final.callPackage ./ha-components/promql.nix {};
  ha-component-zha-toolkit = final.callPackage ./ha-components/zha-toolkit.nix {};

  # meli = pkgs.meli.override {
  #   cargoBuildFlags = ["--features jmap"];
  # };

  steam-with-packages = final.steam.override {
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
