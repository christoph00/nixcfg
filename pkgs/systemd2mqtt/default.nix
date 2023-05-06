{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  stdenv,
  darwin,
}:
rustPlatform.buildRustPackage rec {
  pname = "systemd2mqtt";
  version = "unstable-2022-12-19";

  src = fetchFromGitHub {
    owner = "arcnmx";
    repo = "systemd2mqtt";
    rev = "a32c3e1ed052cdf35f79640f1a224518acb69fb5";
    hash = "sha256-q14YY7ByTVIDCE4sX5tJ2Eo4m+jDK+rOs41mD+rpA+c=";
  };

  cargoHash = "sha256-pHbs/JEzZ7lB1si8VhtGeKWrNQQCdp+y6Mp7ikY4E3w=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs =
    [
      openssl
    ]
    ++ lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.Security
    ];

  meta = with lib; {
    description = "Expose systemd services to mqtt";
    homepage = "https://github.com/arcnmx/systemd2mqtt";
    license = with licenses; [];
    maintainers = with maintainers; [];
  };
}
