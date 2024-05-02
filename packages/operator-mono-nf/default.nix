{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation rec {
  pname = "operator-mono-nf";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "TarunDaCoder";
    repo = "OperatorMono_NerdFont";
    rev = "d8e2ac4d8ec637cf02e8847870b882a0c6ce6034";
    sha256 = "sha256-jECkRLoBOYe6SUliAY4CeCFt9jT2GjS6bLA7c/N4uaY=";
  };

  installPhase = ''
    mkdir -p $out/share/fonts/${pname}
    cp -t $out/share/fonts/${pname} **/*.otf
  '';

  meta = with lib; {
    description = "The famous $600 Operator Mono font, but for free and with nerd fonts patched";
    license = licenses.unfree;
    homepage = "https://github.com/TarunDaCoder/OperatorMono_NerdFont";
    maintainers = with maintainers; [ ];
  };
}
