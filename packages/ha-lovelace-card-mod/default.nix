{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "ha-lovelace-card-mod";
  version = "3.2.4";

  src = fetchFromGitHub {
    owner = "thomasloven";
    repo = "lovelace-card-mod";
    rev = version;
    hash = "sha256-JU8IZiQFWUDuUOUENLv8ffQQn6Z07PxA+674ogGNrac=";
  };

  installPhase = ''
    mkdir $out
    cp -v card-mod.js $out/
  '';

  meta = with lib; {
    description = "Add CSS styles to (almost) any lovelace card";
    homepage = "https://github.com/thomasloven/lovelace-card-mod";
    license = licenses.mit;
    maintainers = with maintainers; [];
    platforms = platforms.all;
  };
}
