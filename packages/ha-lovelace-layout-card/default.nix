{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "ha-lovelace-layout-card";
  version = "2.4.4";

  src = fetchFromGitHub {
    owner = "thomasloven";
    repo = "lovelace-layout-card";
    rev = version;
    hash = "sha256-/NKtzv1wWQNfwEYc0Y5It1NeBCU+Tg/jCYBB92uINT4=";
  };

  installPhase = ''
    mkdir $out
    cp -v layout-card.js $out/
  '';

  meta = with lib; {
    description = "Get more control over the placement of lovelace cards";
    homepage = "https://github.com/thomasloven/lovelace-layout-card";
    license = licenses.mit;
    maintainers = with maintainers; [];
    platforms = platforms.all;
  };
}
