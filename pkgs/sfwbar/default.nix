{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  gtk3,
  gtk-layer-shell,
  json_c,
}:
stdenv.mkDerivation rec {
  pname = "sfwbar";
  version = "1.0_beta9";

  src = fetchFromGitHub {
    owner = "LBCrion";
    repo = pname;
    rev = "v${version}";
    sha256 = "1f10wxl9v38wzbx3arvp84pwn2skwinfah79y4ckz05l2ycbsy15";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];
  buildInputs = [gtk3 gtk-layer-shell json_c];

  #mesonFlags = [];

  doCheck = false;

  meta = with lib; {
    description = "Sway Floating Window Bar";
    homepage = "https://github.com/LBCrion/sfwbar";
    license = licenses.lgpl21Plus;
    platforms = platforms.unix;
  };
}
