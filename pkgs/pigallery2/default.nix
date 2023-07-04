{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:
buildNpmPackage rec {
  pname = "pigallery2";
  version = "1.9.5";

  src = fetchFromGitHub {
    owner = "bpatrik";
    repo = "pigallery2";
    rev = version;
    hash = "sha256-BOEnOwXP38hv6dH42cXXF8VHgfIh9F1uUjBI6esOtvM=";
  };

  npmDepsHash = "sha256-2skWgYAv1qmLfn18lMOk24zrsdyBzYTP1zj9urf9qx8=";

  meta = with lib; {
    description = "A fast directory-first photo gallery website, with rich UI,  optimized for running on low resource servers (especially on raspberry pi";
    homepage = "https://github.com/bpatrik/pigallery2";
    license = licenses.mit;
    maintainers = with maintainers; [];
  };
}
