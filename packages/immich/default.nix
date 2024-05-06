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
}: let
  pname = "immich";
  version = "1.103.1";
  src = fetchFromGitHub {
    owner = "immich-app";
    repo = "immich";
    rev = "v${version}";
    hash = "sha256-/NtL24C2eUeDDJjJ8jwlpqtEQOwqDkIxv8w2VMtD1yg=";
    fetchSubmodules = true;
  };

  openapi = buildNpmPackage {
    inherit version;
    pname = "${pname}-openapi";
    src = "${src}/open-api/typescript-sdk";

    buildPhase = ''
      runHook preBuild
      mkdir dist
      npm run build --offline -- --output-path=dist
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir $out
      cp -r dist/* $out
      runHook postInstall
    '';
  };

  web = buildNpmPackage {
    inherit version;
    pname = "${pname}-web";
    src = "${src}/web";

    npmDepsHash = "sha256-yzDGBrhG3FvgZzQG1d5Bv6GzQB1fybYFqjgePgLn3m0=";

    postPatch = ''
      substituteInPlace package.json --replace 'file:../open-api/typescript-sdk' "file:${openapi}"
    '';
  };
in
  buildNpmPackage rec {
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
      cp -r ${web}  $out/web
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
      homepage = "https://github.com/immich-app/immich";
      license = licenses.agpl3Only;
      maintainers = with maintainers; [];
      platforms = platforms.all;
    };
  }
