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

  hash =
    {
      x86_64-linux = "sha256-JZWDLGXy6QG6bOUoFu9uPtY1vk3yvs5sUioMYuqywNc=";

      aarch64-linux = "05b9rphq69gra07gcpd1blmak1dgdspgdvm7vrvsbnz7nxyz3gdg";
    }
    .${system}
    or throwSystem;
in
  stdenv.mkDerivation rec {
    pname = "vscode-vscode-cli";
    version = "1.74.2";
    src = fetchurl {
      name = "VSCode-CLI_${version}_${plat}.tar.tar.gz";

      url = "https://update.code.visualstudio.com/${version}/${plat}/stable";

      inherit hash;
    };
    nativeBuildInputs = [autoPatchelfHook];
    buildInputs = [];
    sourceRoot = ".";
    installPhase = ''install -m755 -D code $out/bin/code-cli '';
  }
