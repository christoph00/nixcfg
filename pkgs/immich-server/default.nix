{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  prefetch-npm-deps,
  runCommand,
  pkg-config,
  python3,
  vips,
}:
buildNpmPackage rec {
  pname = "immich-server";
  version = "1.60.0";

  src = fetchFromGitHub {
    owner = "immich-app";
    repo = "immich";
    rev = "v${version}";
    hash = "sha256-+tM9lDowKbN77c3W1ev42WYOHlP8guruzN9/RGl2Bew=";
  };

  npmDepsHash = lib.fakeSha256;

  nativeBuildInputs = [
    pkg-config
    python3
  ];

  buildInputs = [
    vips
  ];

  makeCacheWritable = true;
  npmRebuildFlags = [ "--ignore-scripts" ];

  meta = with lib; {
    description = "Self-hosted photo and video backup solution directly from your mobile phone";
    homepage = "https://github.com/immich-app/immich";
    license = licenses.mit;
    maintainers = with maintainers; [];
  };
}
