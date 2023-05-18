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
  version = "unstable-2023-05-18";

  src = fetchFromGitHub {
    owner = "john30";
    repo = "ebusd";
    rev = "773a4dd661794aae12433aa5edc5715b0d1e038e";
    sha256 = "0p1brplshvhvddq1nc3jxxic9ad6wnzrk69l0aba1dnyca8xvmvq";
  };

  nativeBuildInputs = [
    cmake
    mosquitto
    openssl
  ];

  postPatch = ''
    mkdir -p $out
    substituteInPlace CMakeLists.txt \
      --replace "DESTINATION /etc" "DESTINATION etc" \
  '';

  preAutoreconf = "./autogen.sh";

  # postConfigure = ''
  # ls -lah
  # cat cmake_install.cmake
  # '';

  meta = with lib; {
    description = "Daemon for communication with eBUS heating systems";
    homepage = "https://github.com/john30/ebusd";
    changelog = "https://github.com/john30/ebusd/blob/${src.rev}/ChangeLog.md";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [];
  };
}
