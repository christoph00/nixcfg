{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  vips,
  pkg-config,
  python3,
  nest-cli,
  nodejs,
  bash,
}:
buildNpmPackage rec {
  pname = "immich-server";
  version = "1.103.1";

  src = fetchFromGitHub {
    owner = "immich-app";
    repo = "immich";
    rev = "v${version}";
    hash = "sha256-/NtL24C2eUeDDJjJ8jwlpqtEQOwqDkIxv8w2VMtD1yg=";
    fetchSubmodules = true;
  };

  npmDepsHash = "sha256-hrdswSsQFKu7i214H082FU7BpS/OUp+6tCw4rY5ccRQ=";

  sourceRoot = "${src.name}/server";

  nativeBuildInputs = [
    pkg-config
    python3
    nest-cli
  ];

  buildPhase = ''
    nest build
  '';

  installPhase = ''
    mkdir -p $out
    cp -r dist/* $out/
    cp -a \
    resources \
    package.json \
    package-lock.json \
    node_modules \
    $out/
  '';

  buildInputs = [
    vips
  ];

  meta = with lib; {
    description = "High performance self-hosted photo and video management solution";
    homepage = "https://github.com/immich-app/immich/server";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [];
    mainProgram = "immich-server";
    platforms = platforms.all;
  };
}
