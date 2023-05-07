{
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "ha-lovelace-mushroom";
  version = "2.7.1";

  src = let
    owner = "piitaya";
    repo = "lovelace-mushroom";
    sha256 = "1iadpss7agks2wvqi3px6akl4bqymkg83g1f3y65b27dpsg3cwm2";
  in
    fetchurl {
      url = "https://github.com/${owner}/${repo}/releases/download/v${version}/mushroom.js";
      inherit sha256;
    };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out
    cp $src $out/${pname}.js
  '';
}
