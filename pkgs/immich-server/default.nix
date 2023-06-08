{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  prefetch-npm-deps,
  runCommand,
  pkg-config,
  python3,
  vips,
  nest-cli,
}:
buildNpmPackage rec {
  pname = "immich-server";
  version = "1.60.0";

  src =
    fetchFromGitHub {
      owner = "immich-app";
      repo = "immich";
      rev = "v${version}";
      hash = "sha256-+tM9lDowKbN77c3W1ev42WYOHlP8guruzN9/RGl2Bew=";
    }
    + "/server";

  npmDepsHash = "sha256-OTEPNIQZfKsur0h2Nm97nJ8lI23HjBj3JW74mAoy8Cw=";

  nativeBuildInputs = [
    pkg-config
    python3
    nest-cli
  ];

  buildInputs = [
    vips
  ];

  buildPhase = ''
    runHook preBuild
    npm run build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir $out
    cp -r node_modules $out/node_modules
    cp -r bin $out/bin
    cp -r dist $out/dist
    runHook postInstall
  '';

  makeCacheWritable = true;

  meta = with lib; {
    description = "Self-hosted photo and video backup solution directly from your mobile phone";
    homepage = "https://github.com/immich-app/immich";
    license = licenses.mit;
    maintainers = with maintainers; [];
  };
}
