{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, openssl
, stdenv
, darwin
}:

rustPlatform.buildRustPackage rec {
  pname = "dlm";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "agourlay";
    repo = "dlm";
    rev = "v${version}";
    hash = "sha256-2Syd4d6Tf3FgdoNxcjFXSu1YjENuV5vWAoKJHGsFVvA=";
  };

  cargoHash = "sha256-ivHZtchC6xrgm5kAurObUyS0BqhATLs6+HH42/FZiCg=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.CoreFoundation
    darwin.apple_sdk.frameworks.Security
  ];

  meta = with lib; {
    description = "Minimal HTTP download manager";
    homepage = "https://github.com/agourlay/dlm";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
  };
}
