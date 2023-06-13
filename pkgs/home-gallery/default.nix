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

  src =
    fetchFromGitHub {
      owner = "xemlep";
      repo = "home-gallery";
      rev = "v${version}";
      sha256 = "0zvflb2qy8501qqzf2nhs8imls3s41nmb4xkiybcy3pj5v95pw25";
    }
    + "/server";

  npmDepsSha256 = "${lib.fakeSha256}";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
  ];




  makeCacheWritable = true;

  meta = with lib; {
    description = "consume, browse and discover all my personal photos and videos.";
    homepage = "https://home-gallery.org";
    license = licenses.mit;
    maintainers = with maintainers; [];
  };
}
