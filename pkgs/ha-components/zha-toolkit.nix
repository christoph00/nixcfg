{
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation rec {
  pname = "ha-component-zha-toolkit";
  version = "0.8.39";

  src = fetchFromGitHub {
    owner = "mdeweerd";
    repo = "zha-toolkit";
    rev = "v${version}";
    sha256 = "1s1ldj5kp6z0898i52sjmknhav1qbknnryr8jb55q12384r0x5ah";
  };

  installPhase = ''
    mkdir -p $out
    cp -r custom_components/zha_toolkit $out/
  '';
}
