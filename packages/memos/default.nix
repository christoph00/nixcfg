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
  inputs,
  system,
  buf,
}:
let
  version = "0.19.0";
  src = fetchFromGitHub {
    owner = "usememos";
    repo = "memos";
    rev = "v${version}";
    hash = "sha256-bsIdioZ8Ak5A9W+XdqJhNlJqLulXlqRwSgq6473Yx6U=";
  };

  frontend =
    let
      mkPnpmPackage = inputs.pnpm2nix.packages."${system}".mkPnpmPackage;
      proto = stdenvNoCC.mkDerivation {
        pname = "memos-proto";
        inherit version;
        src = "${src}/proto";

        nativeBuildInputs = [ buf ];

        doCheck = false;

        postPatch = ''
          substituteInPlace buf.gen.yaml \
            --replace-fail '../web' './web'

          substituteInPlace buf.gen.yaml \
            --replace-fail '../api' './api'
        '';

        buildPhase = ''
          runHook preBuild
          export SSL_CERT_FILE="${cacert}/etc/ssl/certs/ca-bundle.crt"
          HOME=$TMPDIR buf generate
          runHook postBuild
        '';

        installPhase = ''
          cp -r ${src}/web $out
          cp -r ${src}/api $out
        '';
      };
    in
    mkPnpmPackage {
      pname = "memos-web";
      inherit version;
      src = "${src}/web";

      installInPlace = true;

      buildPhase = ''

        runHook preBuild




        cp -r ${proto}/web/src/types/proto ./src/types

        npx tsc
        npx vite --clearScreen=false build

        runHook postBuild
      '';
    };
in
buildGoModule rec {
  pname = "memos";
  inherit version src;

  # check will unable to access network in sandbox
  doCheck = false;
  vendorHash = lib.fakeHash;

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
