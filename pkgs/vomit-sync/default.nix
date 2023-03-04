{ lib
, rustPlatform
, fetchFromSourcehut
, pkg-config
, openssl
, stdenv
, darwin
}:

rustPlatform.buildRustPackage rec {
  pname = "vomit-sync";
  version = "0.9.2";

  src = fetchFromSourcehut {
    owner = "~bitfehler";
    repo = "vomit-sync";
    rev = "v${version}";
    hash = "sha256-zvuSo/BbBQVQl0OIedK4t6TogXHI6YXUZwKqYDVHhQ0=";
  };

  cargoHash = "sha256-m4bBXq8xcmGIYufm4d/p5tn0Z8XBTAxwhk1ZRRItcss=";

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
    description = "";
    homepage = "https://git.sr.ht/~bitfehler/vomit-sync";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
  };
}
