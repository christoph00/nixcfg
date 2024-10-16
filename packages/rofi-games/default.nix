{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  cairo,
  glib,
  pango,
}:
rustPlatform.buildRustPackage rec {
  pname = "rofi-games";
  version = "1.10.2";

  src = fetchFromGitHub {
    owner = "Rolv-Apneseth";
    repo = "rofi-games";
    rev = "v${version}";
    hash = "sha256-4L3gk/RG9g5QnUW1AJkZIl0VkBiO/L0HUBC3pibN/qo=";
  };

  cargoHash = "sha256-cU7gp/c1yx3ZLaZuGs1bvOV4AKgLusraILVJ2EhH1iA=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    cairo
    glib
    pango
  ];

  meta = with lib; {
    description = "A rofi plugin which adds a mode that will list available games for launch along with their box art. Requires a good theme for the best results";
    homepage = "https://github.com/Rolv-Apneseth/rofi-games";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ ];
    mainProgram = "rofi-games";
  };
}
