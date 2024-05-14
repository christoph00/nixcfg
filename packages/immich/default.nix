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
  version = "1.104.0";
  src = fetchFromGitHub {
    owner = "immich-app";
    repo = "immich";
    rev = "v${version}";
    hash = "sha256-xHRAxPC7juO4g4f2TvNC87p8YnzcjPS2Vn3wP7NSTi8=";
    #hash = lib.fakeHash;
    fetchSubmodules = true;
  };

  openapi = buildNpmPackage {
    inherit version;
    pname = "${pname}-openapi";
    src = "${src}/open-api/typescript-sdk";

    npmDepsHash = "sha256-TjOhEUCn5SE7xgSwMsFK0wiHkgVmQa13jGezX3KBLWc=";
  };

  web = buildNpmPackage {
    inherit version;
    pname = "${pname}-web";
    src = "${src}/web";

    npmDepsHash = "sha256-VOJhmv+hq8g3KXYPTdbPDPqw/NAltl+tO/VrvKDabiU=";
    #npmDepshash = lib.fakeHash;

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

    npmDepsHash = "sha256-ePTKbrCQh9p3MxjeIMJqBoiS9th5Wb0Vk/3WMACKh0o=";

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
