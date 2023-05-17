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
  version = "unstable-2023-05-01";

  src = fetchFromGitHub {
    owner = "john30";
    repo = "ebusd";
    rev = "1895339e4514a3fbb97f46cdd41170ca3f81ad75";
    sha256 = "1i8gbryd4fvpj1dwcr8ai71a55dmhc9f0wxr7as1fpzp41v5wgyp";
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
