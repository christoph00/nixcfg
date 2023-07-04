{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nodePackages,
  jq,
  moreutils,
}:
stdenvNoCC.mkDerivation rec {
  pname = "vitejs";
  version = "4.3.9";

  src = fetchFromGitHub {
    owner = "vitejs";
    repo = "vite";
    rev = "v${version}";
    hash = "sha256-aJnpN4CoU1bsKB8YDsRYViS/LZ8bZpKa0sllsptZmc0=";
  };

  nativeBuildInputs = [
    nodePackages.pnpm
    nodePackages.typescript
  ];

  buildPhase = ''
    export HOME=$(mktemp -d)
    pnpm config set store-dir $out
    # use --ignore-script and --no-optional to avoid downloading binaries
    # use --frozen-lockfile to avoid checking git deps
    pnpm install --frozen-lockfile --no-optional --ignore-script
    pnpm run build

  '';

  dontFixup = true;

  meta = with lib; {
    description = "Next generation frontend tooling. It's fast";
    homepage = "https://github.com/vitejs/vite";
    license = licenses.mit;
    maintainers = with maintainers; [];
  };
}
