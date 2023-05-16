{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  mosquitto,
  openssl,
}:
stdenv.mkDerivation rec {
  pname = "ebusd";
  version = "23.1";

  src = fetchFromGitHub {
    owner = "john30";
    repo = "ebusd";
    rev = version;
    hash = "sha256-wCD328bzRzdm2A4v+/ta6c8ZqFxbldNo+h6G5rVtmYI=";
  };

  nativeBuildInputs = [
    cmake
    mosquitto
    openssl
  ];


  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "DESTINATION /etc" "DESTINATION etc" \
  '';

  installPhase = ''
    mkdir -p $out
    cd src
    ls -lah
  '';


  meta = with lib; {
    description = "Daemon for communication with eBUS heating systems";
    homepage = "https://github.com/john30/ebusd";
    changelog = "https://github.com/john30/ebusd/blob/${src.rev}/ChangeLog.md";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [];
  };
}
