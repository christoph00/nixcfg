{
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "ha-lovelace-button-card";
  version = "3.5.0";

  src = let
    owner = "custom-cards";
    repo = "button-card";
    sha256 = "0zdl1qksx3bnmgp6qihgynwx5rjnldgks0pvf651a6kiplafphh1";
  in
    fetchurl {
      url = "https://github.com/${owner}/${repo}/releases/download/v${version}/button-card.js";
      inherit sha256;
    };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out
    cp $src $out/${pname}.js
  '';
}
