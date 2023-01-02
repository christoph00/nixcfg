{
  callPackage,
  fetchurl,
  lib,
}: let
  mkWallpaperImgur = callPackage (import ./mkWallpaperImgur.nix) {};
in {
  pixel-landscape01 = mkWallpaperImgur {
    name = "pixel-landscape01";
    id = "NTsLwqk";
    sha256 = "0qjx3qdx334g1rxgvbmhfjbfpwxqavard8msnfgss5ki34p5ajyn";
  };
  pixel-waterfall01 = mkWallpaperImgur {
    name = "pixel-landscape01";
    id = "q3oeNJN";
    sha256 = "0qn922nad0g7yvmh783wdn0ihr094kx9l6xhq763vxafifh9lhs7";
  };
  pixel-campfire01 = mkWallpaperImgur {
    name = "pixel-campfire01";
    id = "OVoN5d4";
    sha256 = "1ksqaahhkr22gmaabyxccv07w5inb221mb2f39ndkgs8v9av5vsr";
  };
}
