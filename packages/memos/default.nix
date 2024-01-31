{
  fetchFromGitHub,
  buildGoModule,
  buildNpmPackage,
  stdenv,
  lib,
  makeWrapper,
  nodePackages,
  cacert,
  stdenvNoCC,
  jq,
  moreutils,
}: let
  version = "0.19.0";
  src = fetchFromGitHub {
    owner = "usememos";
    repo = "memos";
    rev = "v${version}";
    hash = "sha256-lcOZg5mlFPp04ZCm5GDhQfSwE2ahSmGhmdAw+pygK0A=";
  };

  frontend = stdenv.mkDerivation (finalAttrs: {
    pname = "memos-web";
    inherit version;

    src = "${src}/web";

    pnpmDeps = assert lib.versionAtLeast nodePackages.pnpm.version "8.10.0";
      stdenvNoCC.mkDerivation {
        pname = "${finalAttrs.pname}-pnpm-deps";
        inherit (finalAttrs) src version;

        nativeBuildInputs = [
          jq
          moreutils
          nodePackages.pnpm
          cacert
        ];

        pnpmPatch = builtins.toJSON {
          pnpm.supportedArchitectures = {
            os = ["linux"];
            cpu = ["x64" "arm64"];
          };
        };

        postPatch = ''
          mv package.json package.json.orig
          jq --raw-output ". * $pnpmPatch" package.json.orig > package.json
        '';
        installPhase = ''
          export HOME=$(mktemp -d)

          pnpm config set store-dir $out
          pnpm install --frozen-lockfile --ignore-script

          rm -rf $out/v3/tmp
          for f in $(find $out -name "*.json"); do
            sed -i -E -e 's/"checkedAt":[0-9]+,//g' $f
            jq --sort-keys . $f | sponge $f
          done
        '';

        dontBuild = true;
        dontFixup = true;
        outputHashMode = "recursive";
        outputHash = "sha256-8K4GyEZTuzYo/oXIeXlyV4D1VAlffMmodnwEhHSUxfU=";
      };
    nativeBuildInputs = [
      nodePackages.pnpm
      nodePackages.nodejs
    ];
    preBuild = ''
      export HOME=$(mktemp -d)
      export STORE_PATH=$(mktemp -d)

      cp -Tr "$pnpmDeps" "$STORE_PATH"
      chmod -R +w "$STORE_PATH"

      pnpm config set store-dir "$STORE_PATH"
      pnpm install --offline --frozen-lockfile --ignore-script
      patchShebangs node_modules/{*,.*}
    '';

    postBuild = ''
      pnpm build
    '';

    installPhase = ''
      cp -r dist $out/
    '';

    passthru = {
      inherit (finalAttrs) pnpmDeps;
    };
  });
in
  buildGoModule rec {
    pname = "memos";
    inherit version src;

    # check will unable to access network in sandbox
    doCheck = false;
    vendorHash = "sha256-UM/xeRvfvlq+jGzWpc3EU5GJ6Dt7RmTbSt9h3da6f8w=";

    # Inject frontend assets into go embed
    prePatch = ''
      rm -rf server/dist
      cp -r ${frontend} server/dist
    '';

    meta = with lib; {
      homepage = "https://usememos.com";
      description = "A lightweight, self-hosted memo hub";
      license = licenses.mit;
      mainProgram = "memos";
    };
  }
