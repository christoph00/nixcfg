{
  lib,
  rustPlatform,
  fetchFromGitHub,
  stdenv,
  darwin,
}:
rustPlatform.buildRustPackage rec {
  pname = "stalwart-imap";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "stalwartlabs";
    repo = "imap-server";
    rev = "v${version}";
    hash = "sha256-XrLhriVaLNkBJKtRr/U8yD/RWdT+1OzhW0iAxITEOfc=";
  };

  cargoHash = "sha256-2OeAcxpHHvhoVuxhYdQbTHsI8Om2nyIz32tov+22jHA=";

  buildInputs = lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.CoreFoundation
  ];

  meta = with lib; {
    description = "Stalwart IMAP server";
    homepage = "https://github.com/stalwartlabs/imap-server";
    changelog = "https://github.com/stalwartlabs/imap-server/blob/${src.rev}/CHANGELOG";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [];
  };
}
