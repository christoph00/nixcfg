{
  lib,
  mkKdeDerivation ,
  pkg-config,
  wayland,
  freerdp,
}:
mkKdeDerivation rec {
  pname = "krdp";

  



  extraBuildInputs  = [
    pkg-config
    freerdp
    wayland
  ];

  meta = with lib; {
    description = "Library and examples for creating an RDP server";
    homepage = "https://invent.kde.org/plasma/krdp";
    license = licenses.unfree; # FIXME: nix-init did not found a license
    maintainers = with maintainers; [];
    mainProgram = "krdp";
    platforms = platforms.all;
  };
}
