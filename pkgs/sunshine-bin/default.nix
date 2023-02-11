{
  lib,
  makeDesktopItem,
  copyDesktopItems,
  stdenvNoCC,
  fetchurl,
  appimageTools,
}: let
  pname = "sunshine-bin";
  version = "0.18.1";
  src = fetchurl {
    url = "https://github.com/LizardByte/Sunshine/releases/download/v${version}/sunshine.AppImage";
    sha256 = "0qr473xmj7355cif68z7l4vidvx7wq8i7qxx4xa3fz0dbabvb2az";
  };
  appimage = appimageTools.wrapType2 {inherit version pname src;};
in
  stdenvNoCC.mkDerivation {
    inherit version pname;
    src = appimage;

    nativeBuildInputs = [copyDesktopItems];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/
      cp -r bin $out/bin

      runHook postInstall
    '';

    meta = with lib; {
      description = "Sunshine is a Gamestream host for Moonlight.";
      homepage = "https://github.com/LizardByte/Sunshine";
      license = licenses.gpl3Only;
      platforms = platforms.linux;
    };
  }
