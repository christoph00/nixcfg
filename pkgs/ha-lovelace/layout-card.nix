{
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
    sha256 = "0gimi1mzfhc017ihykiy4l25wlxp927d2726q1gh6nbhzp7avlpw";
  };

  installPhase = ''
    mkdir -p $out
    cp layout-card.js $out/${pname}.js
  '';
}
