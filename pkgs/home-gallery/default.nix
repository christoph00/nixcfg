{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  prefetch-npm-deps,
  pkg-config,
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

  npmDepsSha256 = "${lib.fakeSha256}";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
  ];

  makeCacheWritable = true;

  meta = with lib; {
    description = "Self-hosted open-source web gallery to view your photos and videos featuring mobile-friendly, tagging and AI powered image discovery";
    homepage = "https://github.com/xemle/home-gallery";
    changelog = "https://github.com/xemle/home-gallery/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [];
  };
}
