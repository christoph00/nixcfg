{
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "ha-lovelace-vacuum-card";
  version = "2.6.3";

  src = let
    owner = "denysdovhan";
    repo = "vacuum-card";
    sha256 = "1yy9bj6dpaq3h9pacwjnz1jywg70m6njpf4968abqfiyfnvs7699";
  in
    fetchurl {
      url = "https://github.com/${owner}/${repo}/releases/download/v${version}/vacuum-card.js";
      inherit sha256;
    };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out
    cp $src $out/${pname}.js
  '';
}
