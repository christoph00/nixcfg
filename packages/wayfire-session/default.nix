{
  lib,
  stdenv,
  pkgs,
  ...
}:
let
  wayfire = ''
    [Desktop Entry]
    Name=Wayfire
    Comment=Wayfire WM
    Exec=wayfire
    Type=Application
  '';
in
stdenv.mkDerivation rec {
  name = "wayfire-session";

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/share/wayland-sessions
    mkdir -p $out/share/xsessions
    echo "${wayfire}" > $out/share/wayland-sessions/wayfire.desktop
  '';

  passthru.providedSessions = [ "wayfire" ];
}
