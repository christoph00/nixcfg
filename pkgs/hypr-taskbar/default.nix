{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "hypr-taskbar";
  version = "unstable-2023-02-08";

  src = fetchFromGitHub {
    owner = "horriblename";
    repo = "hypr-taskbar";
    rev = "82bfb4eae9e0227d58104f7731ea8d1cdb605a02";
    hash = "sha256-sHiEdSxnBVck2EBWcDjuDmtcwwTOBPkSKciNb7Ha70c=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "freedesktop-desktop-entry-0.5.0" = "sha256-GCx06HZWeGR92+oIT7ba9saNMaJbYULy9kfnLmQ7P94=";
      "hyprland-0.3.0" = "sha256-gV08x+WRADX9Y3dqW0mcKYu3TJaaRMMgRztrYbTdWN8=";
    };
  };

  meta = with lib; {
    description = "A taskbar module for hyprland designed for eww";
    homepage = "https://github.com/horriblename/hypr-taskbar";
    license = with licenses; [];
    maintainers = with maintainers; [];
  };
}
