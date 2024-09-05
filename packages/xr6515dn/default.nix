{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "xerox-workcentre-6515DN";
  version = "5.519";

  src = fetchFromGitHub {
    owner = "tuuxx";
    repo = "Xerox-6515";
    rev = "c52b4b46131bd9b3a0c54de4f2a7853b4b016f64";
    sha256 = "1mbxwsggm13vigs4avci7d1nl16n87lvyl7h01f9bydmysijzz72";
  };

  phases = ["installPhase"];

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/share/cups/model/xerox-workcentre-6515DN
    cd ${src}
    cp *.ppd $out/share/cups/model/xerox-workcentre-6515DN/
  '';

  meta = with lib; {
    homepage = "https://github.com/tuuxx/Xerox-6515";
    description = "Xerox WorkCentre 6515 Drivers";
    platforms = platforms.linux;
  };
}
