{
  lib,
  buildNpmPackage,
  substituteAll,
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

    npmDepsHash = "sha256-tKuhaheR0l6/9XmnYpUod+g8GLup/6LZ3K0dftdfw0s=";
  };

  web = buildNpmPackage {
    inherit version;
    pname = "${pname}-web";
    src = "${src}/web";

    npmDepsHash = "sha256-vs6QEGIfbGCtTCXQDmWYBf/eKbB7lPEJzvTHzPfjQvY=";

    makeCacheWritable = true;

    postPatch = ''
      substituteInPlace package.json --replace-fail 'file:../open-api/typescript-sdk' "${version}"

      substituteInPlace package-lock.json --replace-fail 'file:../open-api/typescript-sdk' "${version}"
    '';

    postConfigure = ''
      npm install ${openapi}/lib/node_modules/@immich/sdk
    '';

    installPhase = ''
      mkdir -p $out
      cp -a \
        build/* \
        static \
        $out/
    '';
  };
in
  buildNpmPackage rec {
    inherit pname src version;

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
