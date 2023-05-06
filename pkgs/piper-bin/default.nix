{
  pkgs,
  stdenv,
  autoPatchelfHook,
  fetchurl,
  ...
}: let
  inherit (stdenv.hostPlatform) system;

  throwSystem = throw "Unsupported system: ${system}";

  plat =
    {
      x86_64-linux = "amd64";

      aarch64-linux = "arm64";
    }
    .${system}
    or throwSystem;

  sha256 =
    {
      x86_64-linux = "sha256-ccUTb5rDOcZTwfCB2KSJ9pxkS75dsUq2hy7e5IRP/VI=";

      aarch64-linux = "06bjhywlb3gr8xi6fyrh5ydfg9zai3xjd3bv975y1qi185mwzn5y";
    }
    .${system}
    or throwSystem;
in
  stdenv.mkDerivation rec {
    pname = "piper-bin";
    version = "0.0.2";
    src = fetchurl {
      name = "piper_${plat}.tar.gz";

      url = "https://github.com/rhasspy/piper/releases/download/v${version}/piper_${plat}.tar.gz";

      inherit sha256;
    };
    nativeBuildInputs = [autoPatchelfHook];
    buildInputs = [];
    sourceRoot = ".";
    installPhase = ''install -m755 -D code $out/bin/code-cli '';
  }
