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
      x86_64-linux = "cli-alpine-x64";

      aarch64-linux = "cli-alpine-arm64";
    }
    .${system}
    or throwSystem;

  sha256 =
    {
      x86_64-linux = "sha256-8phu17dn1sR6/n+Lj+ADjetobvSucf19BGnXOp8PqsA=";

      aarch64-linux = "05b9rphq69gra07gcpd1blmak1dgdspgdvm7vrvsbnz7nxyz3gdg";
    }
    .${system}
    or throwSystem;
in
  stdenv.mkDerivation rec {
    pname = "vscode-cli";
    version = "1.74.2";
    src = fetchurl {
      name = "VSCode-CLI_${version}_${plat}.tar.gz";

      url = "https://update.code.visualstudio.com/${version}/${plat}/stable";

      inherit sha256;
    };
    nativeBuildInputs = [autoPatchelfHook];
    buildInputs = [];
    sourceRoot = ".";
    installPhase = ''install -m755 -D code $out/bin/code-cli '';
  }
