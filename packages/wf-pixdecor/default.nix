{
  stdenv,
  lib,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  wayfire,
  wf-config,
  wayland,
  pango,
  eudev,
  libinput,
  libxkbcommon,
  librsvg,
  libGL,
  xorg,
}:
stdenv.mkDerivation rec {
  pname = "wf-pixdecor";
  version = "unstable-2024-03-09";

  src = fetchFromGitHub {
    owner = "soreau";
    repo = "pixdecor";
    rev = "d172e8438ee97edb50f0c31edd901ddf7940085d";
    hash = "sha256-55Ni6/LvAhS2GGCo58GKoyHJLl4idzLT+bWYTVImmsQ=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    wayfire
    wf-config
    wayland
    pango
    eudev
    libinput
    libxkbcommon
    librsvg
    libGL
    xorg.xcbutilwm
  ];

  mesonFlags = [ "--sysconfdir /etc" ];

  postPatch =
    let
      substitute = ''--replace-warn "wayfire.get_variable( pkgconfig: 'metadatadir' )" "join_paths(get_option('prefix'), 'share/wayfire/metadata')"'';
    in
    ''
      substituteInPlace meson.build ${substitute} && \
            substituteInPlace src/meson.build ${substitute} && \
            substituteInPlace metadata/meson.build ${substitute}
    '';

  meta = with lib; {
    description = "Pixdecor plugin";
    homepage = "https://github.com/soreau/pixdecor";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "wf-pixdecor";
    inherit (wayfire.meta) platforms;
  };
}
