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
  makeWrapper,
}: let
  pname = "immich";
  version = "1.105.1";
  src = fetchFromGitHub {
    owner = "immich-app";
    repo = "immich";
    rev = "v${version}";
    hash = "sha256-94OPpruPaj1+6nswWoDnG//FI0R1TMf8sF9VAYnvDM0=";
    #hash = lib.fakeHash;
    fetchSubmodules = true;
  };

  openapi = buildNpmPackage {
    inherit version;
    pname = "${pname}-openapi";
    src = "${src}/open-api/typescript-sdk";

    npmDepsHash = "sha256-nWL59R3m9wqxo7tZl4c7izA0ct74ge8q/GPH+WY7XMU=";
    #npmDepshash = lib.fakeHash;
  };

  web = buildNpmPackage {
    inherit version src;
    pname = "${pname}-web";

    sourceRoot = "${src.name}/web";

    npmDepsHash = "sha256-8SKgC+RCnZNoVN4q5GEs6oh3FzdU2ePZyNuQDd9JOBA=";
    #npmDepshash = lib.fakeHash;

    #postPatch = ''
    #  substituteInPlace package.json --replace-fail 'file:../open-api/typescript-sdk' "${version}"#
    #
    #'';
    #   substituteInPlace package-lock.json --replace-fail 'file:../open-api/typescript-sdk' "${version}"
    #  substituteInPlace package-lock.json --replace-fail "../open-api/typescript-sdk" "${openapi}/lib/node_modules/@immich/sdk"

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

    npmDepsHash = "sha256-GqSzo16RHGvr75vE5EEyVljVI/tdOoictE46dWDz8bg=";
    #npmDepshash = lib.fakeHash;

    sourceRoot = "${src.name}/server";

    nativeBuildInputs = [
      pkg-config
      python3
      nest-cli
      makeWrapper
    ];

    buildPhase = ''
      nest build
    '';

    installPhase = ''
      mkdir -p $out
      cp -r dist $out/
      cp -r ${web}  $out/web
      cp -a \
        resources \
        package.json \
        package-lock.json \
        node_modules \
        $out/

      makeWrapper ${nodejs}/bin/node $out/bin/immich \
        --add-flags $out/dist/main.js \
        --set NODE_ENV production \
        --set NODE_PATH "$out/node_modules"
    '';

    postFixup = ''

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
