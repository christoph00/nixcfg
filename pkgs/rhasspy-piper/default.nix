{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "rhasspy-piper";
  version = "0.0.2";

  src = fetchFromGitHub {
    owner = "rhasspy";
    repo = "piper";
    rev = "v${version}";
    hash = "sha256-6SZ1T2A1DyVmBH2pJBHJdsnniRuLrI/dthRTRRyVSQQ=";
  };

  meta = with lib; {
    description = "A fast, local neural text to speech system";
    homepage = "https://github.com/rhasspy/piper";
    license = licenses.mit;
    maintainers = with maintainers; [];
  };
}
