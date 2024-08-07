{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "ha-lovelace-atomic-calendar";
  version = "9.2.0-beta.1";

  src = fetchurl {
    url = "https://github.com/totaldebug/atomic-calendar-revive/releases/download/v${version}/atomic-calendar-revive.js";
    sha256 = "0pr6b10yfqwir0xilmhdpnnqvbgxi5azj6vkzsd7vddbwbz0xpin";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir $out
    cp $src $out/mini-media-player-bundle.js
  '';

  meta = with lib; {
    description = "An advanced calendar card for Home Assistant Lovelace";
    homepage = "https://github.com/totaldebug/atomic-calendar-revive";
    license = licenses.mit;
    maintainers = with maintainers; [];
    mainProgram = "ha-lovelace-atomic-calendar";
    platforms = platforms.all;
  };
}
