{
  fetchurl,
  lib,
  stdenv,
}:
stdenv.mkDerivation rec {
  pname = "proton-ge-custom";
  version = "GE-Proton8-4";

  src = fetchurl {
    url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${version}/${version}.tar.gz";
    sha256 = "05q6wzp0r5bbi3z8ycm18xxksq2d84737y26xfwvgcxpf2mgdmai";
  };

  installPhase = ''
    mkdir -p $out
    mv * $out/
  '';

  meta.platforms = lib.platforms.linux;
}
