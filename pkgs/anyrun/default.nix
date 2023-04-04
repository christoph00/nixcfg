{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, atk
, cairo
, gdk-pixbuf
, glib
, gtk3
, openssl
, pango
, stdenv
, darwin
, wayland
}:

rustPlatform.buildRustPackage rec {
  pname = "anyrun";
  version = "unstable-2023-02-12";

  src = fetchFromGitHub {
    owner = "Kirottu";
    repo = "anyrun";
    rev = "9ac2a9a2ebf5667290bf60e4e4ecc03c0caa89cc";
    hash = "sha256-aaveAqYG7TP9Tj91ubBwl75XJSv7vtlF7Jk0Uv8NdTM=";
  };

  cargoHash = "sha256-0feS0Uvjsjr0hhrMQi5rdAcZeuCJEsUDPB8gdm/ZHj0=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    atk
    cairo
    gdk-pixbuf
    glib
    gtk3
    openssl
    pango
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.CoreFoundation
    darwin.apple_sdk.frameworks.Security
  ] ++ lib.optionals stdenv.isLinux [
    wayland
  ];

  meta = with lib; {
    description = "A wayland native, highly customizable runner";
    homepage = "https://github.com/Kirottu/anyrun";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
  };
}
