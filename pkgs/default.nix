{pkgs, ...}: {
  xr6515dn = pkgs.callPackage ./xr6515dn {};
  swww = pkgs.callPackage ./swww {};
  #wallpaper = pkgs.callPackage ./wallpaper {};
  gfn-electron = pkgs.callPackage ./gfn-electron {};
  sftpgo = pkgs.callPackage ./sftpgo {};
  firefox-gnome-theme = pkgs.callPackage ./firefox-gnome-theme {};

  ha-lovelace-battery-entity = pkgs.callPackage ./ha-lovelace/battery-entity.nix {};
  ha-lovelace-fold-entity-row = pkgs.callPackage ./ha-lovelace/fold-entity-row.nix {};
  ha-lovelace-mini-graph-card = pkgs.callPackage ./ha-lovelace/mini-graph-card.nix {};
  ha-lovelace-card-mod = pkgs.callPackage ./ha-lovelace/card-mod.nix {};
  ha-components-better-thermostat = pkgs.callPackage ./ha-components/better_thermostat.nix {};
}
