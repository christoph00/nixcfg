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
  pname = "immich-web";
  version = "1.103.1";

  src = fetchFromGitHub {
    owner = "immich-app";
    repo = "immich";
    rev = "v${version}";
    hash = "sha256-/NtL24C2eUeDDJjJ8jwlpqtEQOwqDkIxv8w2VMtD1yg=";
    fetchSubmodules = true;
  };

  npmDepsHash = "sha256-yzDGBrhG3FvgZzQG1d5Bv6GzQB1fybYFqjgePgLn3m0=";

  sourceRoot = "${src.name}/web";

  npmFlags = ["--legacy-peer-deps"];

  # buildPhase = ''
  #   vite build
  # '';

  # installPhase = ''
  #   mkdir -p $out
  #   cp -r dist/* $out/
  #   cp -a \
  #   resources \
  #   package.json \
  #   package-lock.json \
  #   node_modules \
  #   $out/
  # '';

  meta = with lib; {
    description = "High performance self-hosted photo and video management solution";
    homepage = "https://github.com/immich-app/immich/server";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [];
    mainProgram = "immich-web";
    platforms = platforms.all;
  };
}
