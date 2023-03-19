{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  wrapGAppsHook,
  gtk3,
  gtk-layer-shell,
  json_c,
  glib,
}:
stdenv.mkDerivation rec {
  pname = "sfwbar";
  version = "1.0_beta10";

  src = fetchFromGitHub {
    owner = "LBCrion";
    repo = pname;
    rev = "v${version}";
    sha256 = "1q7hxaqdk80y7s259ikwg3swz7hgp1qcp3q2nxnb81z3rk8qjvaq";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook
  ];
  buildInputs = [gtk3 gtk-layer-shell json_c glib];

  #mesonFlags = [];

  doCheck = false;

  postPatch = ''
    sed -i 's|gio/gdesktopappinfo.h|gio-unix-2.0/gio/gdesktopappinfo.h|' src/scaleimage.c
  '';

  meta = with lib; {
    description = "Sway Floating Window Bar";
    homepage = "https://github.com/LBCrion/sfwbar";
    license = licenses.lgpl21Plus;
    platforms = platforms.unix;
  };
}
