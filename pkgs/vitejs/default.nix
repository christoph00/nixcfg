{ lib
, buildNpmPackage
, fetchFromGitHub
}:

buildNpmPackage rec {
  pname = "vitejs";
  version = "4.3.9";

  src = fetchFromGitHub {
    owner = "vitejs";
    repo = "vite";
    rev = "v${version}";
    hash = "sha256-aJnpN4CoU1bsKB8YDsRYViS/LZ8bZpKa0sllsptZmc0=";
  };

  npmDepsHash = lib.fakeHash;

  meta = with lib; {
    description = "Next generation frontend tooling. It's fast";
    homepage = "https://github.com/vitejs/vite";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
