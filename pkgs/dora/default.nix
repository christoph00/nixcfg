{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  sqlite,
  stdenv,
  darwin,
}:
rustPlatform.buildRustPackage rec {
  pname = "dora";
  version = "unstable-2023-04-13";

  src = fetchFromGitHub {
    owner = "bluecatengineering";
    repo = "dora";
    rev = "617cca0cabbfa4377d0bb6f3122cf1e21378fd30";
    hash = "sha256-Btmlb/B2vUwwMvDtMlwV2KmxsTWL+aL2M/JuLmB3iAI=";
  };

  cargoHash = "sha256-sM8Xma8Ree2e8d7HYK1LWroO/rUFXD6rUDkMTfXdAt8=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs =
    [
      sqlite
    ]
    ++ lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.CoreFoundation
      darwin.apple_sdk.frameworks.Security
    ];

  meta = with lib; {
    description = "A Rust DHCP server";
    homepage = "https://github.com/bluecatengineering/dora";
    license = licenses.mpl20;
    maintainers = with maintainers; [];
  };
}
