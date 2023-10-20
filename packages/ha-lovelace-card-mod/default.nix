{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "lovelace-card-mod";
  version = "3.2.3";

  src = fetchFromGitHub {
    owner = "thomasloven";
    repo = "lovelace-card-mod";
    rev = version;
    hash = "sha256-XTiCwXlUxCYTjCOqRE2Z/fqtbMXvuSTDBBxVC8Z9VrQ=";
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
    mainProgram = "lovelace-card-mod";
    platforms = platforms.all;
  };
}
