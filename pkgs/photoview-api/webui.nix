{ lib
, buildNpmPackage
, fetchFromGitHub
, vite
}:
buildNpmPackage rec {
  pname = "photoview-api";
  version = "2.3.13";

  src = fetchFromGitHub {
    owner = "photoview";
    repo = "photoview";
    rev = "v${version}";
    hash = "sha256-O6k5nbiWTsuOi8YLX0rsZJ9dOIo5d6pdwjhFZrdwI0E=";
  } + "/ui";


  npmDepsHash = lib.fakeHash;

  nativeBuildInputs = [ vite ];
  
  npmInstallFlags = [ "--omit=dev" ];
  makeCacheWritable = true;
  npmRebuildFlags = [ "--ignore-scripts" ];
npmBuildFlags = [
    "--base" "/"
  ];
  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/photoview
    mv apps/web/build $out/share/photoview/ui
    runHook postInstall
  '';
}
