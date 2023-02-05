{
  lib,
  rustPlatform,
  fetchFromGitHub,
  lz4,
  stdenv,
}:
rustPlatform.buildRustPackage rec {
  pname = "swww";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "Horus645";
    repo = pname;
    rev = "v${version}";
    sha256 = "0nx3j7rlhmzxn7w1hhbdd9mza2pakahq5fsqnvy90yfmnxlcm97n";
  };

  cargoSha256 = "sha256-OWe+r8Vh09yfMFBjVH66i+J6RtHo1nDva0m1dJPZ4rE=";

  nativeBuildInputs = [lz4];

  meta = with lib; {
    description = "A Solution to your Wayland Wallpaper Woes";
    homepage = "https://github.com/Horus645/swww";
    license = with licenses; [gpl3];
  };
}
