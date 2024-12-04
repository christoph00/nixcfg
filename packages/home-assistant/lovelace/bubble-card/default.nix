{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "bubble-card";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "Clooos";
    repo = "Bubble-Card";
    rev = "v${version}";
    hash = "0n1lsgvvhf7qa33ayr2z8zfc9n4yb611xsszg4rzibcwsr6dnf0b";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp dist/*.js $out/

    runHook postInstall
  '';

  meta = with lib; {
    changelog =
      "https://github.com/Clooos/Bubble-Card/releases/tag/v${version}";
    description =
      "Bubble Card is a minimalist card collection for Home Assistant with a nice pop-up touch.";
    homepage = "https://github.com/Clooos/Bubble-Card";
    license = licenses.gpl3Plus;
  };
}
