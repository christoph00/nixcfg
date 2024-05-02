{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "ha-lovelace-decluttering-card";
  version = "1.0.0";

  src = fetchurl {
    url = "https://github.com/custom-cards/decluttering-card/releases/download/v${version}/decluttering-card.js";
    sha256 = "14dq15dpnxhmg87hl5wv2lrksqavc5522mwp0qavqilcghn2hml2";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir $out
    cp $src $out/decluttering-card.js
  '';

  meta = with lib; {
    description = "Declutter your lovelace configuration with the help of this card";
    homepage = "https://github.com/custom-cards/decluttering-card";
    changelog = "https://github.com/custom-cards/decluttering-card/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
  };
}
