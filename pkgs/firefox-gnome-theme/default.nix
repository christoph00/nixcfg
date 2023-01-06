{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "firefox-gnome-theme";
  version = "108.1";

  src = fetchFromGitHub {
    owner = "rafaelmardojai";
    repo = pname;
    rev = "v${version}";
    sha256 = "0y364fhpm5pfdgnp2j36rwja6w358srdwgfnicavqf5nh5qajwfn";
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
