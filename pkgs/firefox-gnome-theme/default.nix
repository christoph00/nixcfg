{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "firefox-gnome-theme";
  version = "115";

  src = fetchFromGitHub {
    owner = "rafaelmardojai";
    repo = pname;
    rev = "v${version}";
    sha256 = "050l190iv0zncnrypr01w931lv8bwr4k2k45lq4h0l7m6mscvsv2";
  };

  dontConfigure = true;
  dontBuild = true;
  doCheck = false;

  installPhase = ''
    mkdir -p $out/share/firefox-gnome-theme
    cp -r $src/* $out/share/firefox-gnome-theme
  '';

  meta = with lib; {
    description = "A GNOME theme for Firefox";
    homepage = "https://github.com/rafaelmardojai/firefox-gnome-theme";
    license = licenses.unlicense;
  };
}
