{
  stdenv,
  lib,
  fetchzip,
  autoPatchelfHook,
  alsa-lib,
  freetype,
  fontconfig,
  glib,
  jdk,
  libGL,
  xorg,
  zlib,
  makeDesktopItem,
}:
stdenv.mkDerivation rec {
  pname = "jetbrains-fleet";
  version = "1.25.206";

  # See: https://aur.archlinux.org/packages/jetbrains-fleet
  src = fetchzip {
    url = "https://download-cdn.jetbrains.com/fleet/installers/linux_x64/Fleet-${version}.tar.gz";
    sha256 = "sha256-9TyGc4gCkj2ZpawXaJR9ehmALOckPCeg612o/uYrsXI=";
  };

  sourceRoot = ".";

  dontBuild = true;

  nativeBuildInputs = [autoPatchelfHook];

  buildInputs =
    [
      alsa-lib
      fontconfig
      freetype
      glib
      jdk
      libGL
      stdenv.cc.cc.lib
      zlib
    ]
    ++ (with xorg; [
      libX11
      libXext
      libXi
      libXrender
      libXtst
    ]);

  installPhase = ''
    mkdir -p $out/share/icons
    cp $src/lib/Fleet.png $out/share/icons
    cp -r $src/* $out
  '';

  desktopItem = makeDesktopItem {
    name = "jetbrains-fleet";
    exec = "Fleet";
    icon = "Fleet";
    desktopName = "JetBrains Fleet";
    genericName = "JetBrains Fleet";
    categories = ["Development"];
  };
}
