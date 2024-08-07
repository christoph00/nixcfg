{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  browserpass,
  glib,
  glibc,
  libnotify,
  tridactyl-native,
  udev,
  uget-integrator,
  vulkan-loader,
  xdg-utils,
  xorg,
  autoPatchelfHook,
  dpkg,
  wrapGAppsHook,
}: let
  inherit (lib) makeLibraryPath;
in
  stdenv.mkDerivation rec {
    pname = "mercury-browser";
    version = "121.0.1";

    src = fetchurl {
      url = "https://github.com/Alex313031/Mercury/releases/download/v.${version}/mercury-browser_${version}_amd64.deb";
      hash = "sha256-zgRrTRwdvmx6AhZa8Wvycg2BO0jcfZIIsM7oByVSUaQ=";
    };

    nativeBuildInputs = [
      autoPatchelfHook
      dpkg
      wrapGAppsHook
    ];

    buildInputs = [
      stdenv.cc.cc.lib
      alsa-lib
      browserpass
      glib
      glibc
      libnotify
      tridactyl-native
      udev
      uget-integrator
      vulkan-loader
      xdg-utils
      xorg.libxcb
      xorg.libX11
      xorg.libXcursor
      xorg.libXcomposite
      xorg.libXdamage
      xorg.libXext
      xorg.libXfixes
      xorg.libXi
      xorg.libXrandr
      xorg.libXrender
      xorg.libXtst
      xorg.libXxf86vm
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r usr/* $out

      substituteInPlace $out/share/applications/mercury-browser.desktop \
        --replace StartupWMClass=mercury StartupWMClass=mercury-default

      addAutoPatchelfSearchPath $out/lib/mercury

      substituteInPlace $out/bin/mercury-browser \
        --replace 'export LD_LIBRARY_PATH' "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:${makeLibraryPath buildInputs}:$out/lib/mercury" \
        --replace /usr $out

      runHook postInstall
    '';

    meta = with lib; {
      description = "Firefox fork with compiler optimizations and patches from Librewolf, Waterfox, and GNU IceCat";
      homepage = "https://github.com/Alex313031/Mercury";
      license = licenses.mpl20;
      maintainers = with maintainers; [];
      platforms = platforms.all;
    };
  }
