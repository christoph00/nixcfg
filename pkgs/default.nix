_: {
  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];

  perSystem = {pkgs, ...}: {
    packages = {
      xr6515dn = pkgs.callPackage ./xr6515dn {};
    };
  };
}
