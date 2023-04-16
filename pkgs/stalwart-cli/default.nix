{
  lib,
  rustPlatform,
  fetchFromGitHub,
  stdenv,
  darwin,
}:
rustPlatform.buildRustPackage rec {
  pname = "stalwart-cli";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "stalwartlabs";
    repo = "cli";
    rev = "v${version}";
    hash = "sha256-sVhfSdTvvdh8ANv+0JhdDGB3VYeOH8DaQrUpGWyfCzI=";
  };

  cargoHash = "sha256-d//k2XBswBn3Mb9dQ0aZCDlq/eQG20p/0EyxVF0jhS8=";

  buildInputs = lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.CoreFoundation
  ];

  meta = with lib; {
    description = "Stalwart Mail Server Command Line Interface";
    homepage = "https://github.com/stalwartlabs/cli";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [];
  };
}
