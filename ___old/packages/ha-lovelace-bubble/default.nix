{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "ha-lovelace-bubble";
  version = "1.2.4";

  src = fetchFromGitHub {
    owner = "Clooos";
    repo = "Bubble-Card";
    rev = "v${version}";
    hash = "sha256-41g7NuqeWiab0Nv74ARG5GtOc7qQV0qXqaFgnsZP8Bg=";
  };

  installPhase = ''
    mkdir $out
    cp -v bubble-card.js $out/
  '';

  meta = with lib; {
    description = "Bubble Card is a minimalist card collection for Home Assistant with a nice pop-up touch";
    homepage = "https://github.com/Clooos/Bubble-Card";
    license = licenses.mit;
    maintainers = with maintainers; [];
    mainProgram = "ha-lovelace-bubble";
    platforms = platforms.all;
  };
}
