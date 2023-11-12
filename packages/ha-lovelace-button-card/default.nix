{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "ha-lovelace-button-card";
  version = "4.1.1";

  src = fetchurl {
    url = "https://github.com/custom-cards/button-card/releases/download/v${version}/button-card.js";
    sha256 = "0bx0wk426bb83vpqc5j0waxaizx250s7d53krqnqxf67nq6s0gkp";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir $out
    cp $src $out/button-card.js
  '';

  meta = with lib; {
    description = "Lovelace button-card for home assistant";
    homepage = "https://github.com/custom-cards/button-card";
    changelog = "https://github.com/custom-cards/button-card/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [];
    mainProgram = "ha-lovelace-button-card";
    platforms = platforms.all;
  };
}
