{
  lib,
  rustPlatform,
  fetchFromSourcehut,
  pkg-config,
  openssl,
  stdenv,
  darwin,
}:
rustPlatform.buildRustPackage rec {
  pname = "vmt";
  version = "0.7.0";

  src = fetchFromSourcehut {
    owner = "~bitfehler";
    repo = "vmt";
    rev = "v${version}";
    hash = "sha256-2y00lKNv0twLDufd2F2+d4b4RfFCN7+AU494LC1gbN8=";
  };

  cargoHash = "sha256-ITj84ZU8CLh5wzpYvFFQrEizrf3rO+YiYBVPwhNGcws=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs =
    [
      openssl
    ]
    ++ lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.CoreFoundation
      darwin.apple_sdk.frameworks.Security
    ];

  meta = with lib; {
    description = "";
    homepage = "https://git.sr.ht/~bitfehler/vmt";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [];
  };
}
