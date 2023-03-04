{
  lib,
  rustPlatform,
  fetchFromGitHub,
  cmake,
  pkg-config,
  bzip2,
  clang,
  llvm,
  llvmPackages,
  openssl,
  zlib,
  stdenv,
  darwin,
}:
rustPlatform.buildRustPackage rec {
  pname = "stalwart-jmap";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "stalwartlabs";
    repo = "jmap-server";
    rev = "v${version}";
    hash = "sha256-rTOcong1F3+gM6Adi6pB1wvS/fiGoKHz+FyTb/edVhg=";
  };

  cargoHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  cargoPatches = [./0001-fix-cargo.patch];

  nativeBuildInputs = [
    cmake
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs =
    [
      bzip2
      clang
      llvm
      llvmPackages.libclang
      openssl
      zlib
    ]
    ++ lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.CoreFoundation
      darwin.apple_sdk.frameworks.Security
    ];

  meta = with lib; {
    description = "Stalwart JMAP server";
    homepage = "https://github.com/stalwartlabs/jmap-server";
    changelog = "https://github.com/stalwartlabs/jmap-server/blob/${src.rev}/CHANGELOG";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [];
  };
}
