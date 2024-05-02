{
  stdenv,
  lib,
  fetchFromGitHub,
  extra-cmake-modules,
  plasma5Packages,
  writeShellScript,
  nix-update,
}:
stdenv.mkDerivation rec {
  pname = "klassy";
  version = "4.3.breeze5.27.5";

  src = fetchFromGitHub {
    owner = "paulmcauley";
    repo = "klassy";
    rev = version;
    hash = "sha256-2qs30L7U5kf1Yf+4Pgsjsyaqf9iIaeuRK25Xtn47AYI=";
  };

  outputs = [
    "bin"
    "dev"
    "out"
  ];

  nativeBuildInputs = [
    extra-cmake-modules
    plasma5Packages.wrapQtAppsHook
  ];

  buildInputs = with plasma5Packages; [
    frameworkintegration
    kcmutils
    kconfigwidgets
    kcoreaddons
    kdecoration
    kguiaddons
    ki18n
    kwayland
    kwindowsystem
    plasma-framework
    qtdeclarative
    qtx11extras
  ];

  meta = with lib; {
    description = "A highly customizable binary Window Decoration and Application Style plugin for recent versions of the KDE Plasma desktop";
    inherit (src.meta) homepage;
    license = with licenses; [
      bsd3
      gpl2Plus
      mit
    ];
    platforms = platforms.linux;
  };
}
