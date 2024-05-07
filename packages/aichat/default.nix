{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  oniguruma,
  stdenv,
  darwin,
}:
rustPlatform.buildRustPackage rec {
  pname = "aichat";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "sigoden";
    repo = "aichat";
    rev = "v${version}";
    hash = "sha256-51mdUtCawXU/gSN+OGzgyzYyqa5onLDsEi5FIIa/GFk=";
  };

  cargoHash = "sha256-dRanZt4R1welqp+U/714rOU++/nSs60ZBSeiYimBNZA=";

  nativeBuildInputs = [pkg-config];

  buildInputs =
    [oniguruma]
    ++ lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.AppKit
      darwin.apple_sdk.frameworks.Security
    ];

  env = {
    RUSTONIG_SYSTEM_LIBONIG = true;
  };

  meta = with lib; {
    description = "Use ChatGPT, LocalAI and other LLMs in the terminal";
    homepage = "https://github.com/sigoden/aichat/";
    license = with licenses; [
      mit
      asl20
    ];
    maintainers = with maintainers; [];
    mainProgram = "aichat";
  };
}
