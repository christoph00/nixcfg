{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, stdenv
, wayland
}:

rustPlatform.buildRustPackage rec {
  pname = "wl-gammarelay-rs";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "MaxVerevkin";
    repo = "wl-gammarelay-rs";
    rev = "v${version}";
    hash = "sha256-XiE1ZHBeepNPorp1iPFBN7xmq0heFgIpONMVMTAimR8=";
  };

  cargoHash = "sha256-+VpXOCwmVoPvQbbyy5LX5CvDischNIrjnsoZCVgg08s=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = lib.optionals stdenv.isLinux [
    wayland
  ];

  meta = with lib; {
    description = "A simple program that provides DBus interface to control display temperature and brightness under wayland without flickering";
    homepage = "https://github.com/MaxVerevkin/wl-gammarelay-rs";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
  };
}
