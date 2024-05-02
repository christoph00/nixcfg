{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "firefox-cascade";
  version = "2.7.6";

  src = fetchFromGitHub {
    owner = "andreasgrafen";
    repo = "cascade";
    rev = "v${version}";
    hash = "sha256-XM+mH1wNd24bExLlMfBwRclB07367Iql+mQux3j79Kc=";
  };

  preferLocalBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r ./chrome/* $out/
  '';

  meta = with lib; {
    description = "A responsive One-Line CSS Theme for Firefox";
    homepage = "https://github.com/andreasgrafen/cascade";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "firefox-cascade";
    platforms = platforms.all;
  };
}
