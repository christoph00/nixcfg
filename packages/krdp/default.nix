{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  extra-cmake-modules,
  qtbase,
  wrapQtAppsHook,
  qtwayland,
  pkg-config,
  wayland,
  freerdp,
  kdePackages,
}:
stdenv.mkDerivation rec {
  pname = "krdp";
  version = "unstable-2024-04-23";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "plasma";
    repo = "krdp";
    rev = "668672c506d9b9754e97a4e8507b6cbb58b5c050";
    hash = "sha256-k1Od4C/g9mFBRJniOSeVcRuGrfI2+fJubBxi1a6RRGQ=";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
    qtwayland
    wayland
    freerdp
    kdePackages.kpipewire
  ];

  meta = with lib; {
    description = "Library and examples for creating an RDP server";
    homepage = "https://invent.kde.org/plasma/krdp";
    license = licenses.unfree; # FIXME: nix-init did not found a license
    maintainers = with maintainers; [];
    mainProgram = "krdp";
    platforms = platforms.all;
  };
}
