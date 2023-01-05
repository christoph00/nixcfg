{pkgs, ...}: {
  xr6515dn = pkgs.callPackage ./xr6515dn {};
  swww = pkgs.callPackage ./swww {};
  #wallpaper = pkgs.callPackage ./wallpaper {};
  gfn-electron = pkgs.callPackage ./gfn-electron {};

  ha-lovelace = pkgs.callPackage ./ha-lovelace {};
  ha-components = pkgs.callPackage ./ha-components {};
}
