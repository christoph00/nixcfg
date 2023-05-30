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
  pname = "dlm";
  version = "0.3.5";

  src = fetchFromGitHub {
    owner = "agourlay";
    repo = "dlm";
    rev = "v${version}";
    hash = "sha256-8RHlkd2MZZHzuINPl3/y0FoosUXsgLwzZOrnZpttkW8=";
  };

  cargoHash = "sha256-USv/a+hv8JP11pIVy6kRYbx6H11ckQDLcZm7weOVr/E=";

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
    description = "Minimal HTTP download manager";
    homepage = "https://github.com/agourlay/dlm";
    license = licenses.asl20;
    maintainers = with maintainers; [];
  };
}
