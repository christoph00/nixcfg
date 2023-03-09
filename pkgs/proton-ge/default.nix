{
  fetchurl,
  lib,
  stdenv,
}:
stdenv.mkDerivation rec {
  pname = "proton-ge-custom";
  version = "GE-Proton7-50";

  src = fetchurl {
    url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${version}/${version}.tar.gz";
    sha256 = "1jznryfs622m8592q2w17v8vdpcljqxk48h8dqnvwcq387c7inj0";
  };

  installPhase = ''
    mkdir -p $out
    mv * $out/
  '';

  meta.platforms = lib.platforms.linux;
}
