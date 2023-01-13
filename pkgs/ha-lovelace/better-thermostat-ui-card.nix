{
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "ha-lovelace-better-thermostat-ui-card";
  version = "1.0.4";

  src = let
    owner = "KartoffelToby";
    repo = "better-thermostat-ui-card";
    sha256 = "1hm6yr63ky6lgr79bxmnwpyj695alx3rfzi0aas51a3wln92dy30";
  in
    fetchurl {
      url = "https://github.com/${owner}/${repo}/releases/download/v${version}/better-thermostat-ui-card.js";
      inherit sha256;
    };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out
    cp $src $out/${pname}.js
  '';
}
