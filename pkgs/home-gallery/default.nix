{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  prefetch-npm-deps,
  pkg-config,
  vips,
  ffmpeg,
  libtensorflow,
}:
buildNpmPackage rec {
  pname = "home-gallery";
  version = "1.10.0";

  src = fetchFromGitHub {
    owner = "xemle";
    repo = "home-gallery";
    rev = "v${version}";
    hash = "sha256-RfBb0i7yDs+Wj7OTVW0gemhaI9LQCvcxDqAgj8Wibn8=";
  };

  npmDepsHash = "sha256-wDFfnTApmRPRtmZ/8nH8cpsoyQbpMtKO/Y+dEIENs7I=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    vips
    ffmpeg
    libtensorflow
  ];

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  preConfigure = ''
    node scripts/disable-dependency.js api-server styleguide
    node scripts/disable-dependency.js --prefix=packages/extractor sharp
  '';

  makeCacheWritable = true;

  meta = with lib; {
    description = "Self-hosted open-source web gallery to view your photos and videos featuring mobile-friendly, tagging and AI powered image discovery";
    homepage = "https://github.com/xemle/home-gallery";
    changelog = "https://github.com/xemle/home-gallery/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [];
  };
}
