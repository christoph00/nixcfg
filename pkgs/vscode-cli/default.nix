{
  pkgs,
  stdenv,
  ...
}: let
  inherit (stdenv.hostPlatform) system;

  throwSystem = throw "Unsupported system: ${system}";

  plat =
    {
      x86_64-linux = "linux-x64";

      aarch64-linux = "linux-arm64";
    }
    .${system}
    or throwSystem;

  sha256 =
    {
      x86_64-linux = "";

      aarch64-linux = "";
    }
    .${system}
    or throwSystem;
in
  stdenv.mkDerivation rec {
    pname = "vscode-vscode-cli";
    version = "0";
    src = fetchurl {
      name = "VSCode-CLI_${version}_${plat}.tar.tar.gz";

      url = "https://update.code.visualstudio.com/${version}/${plat}/stable";

      inherit sha2ssha256

    };
    nativeBuildInputs = [autoPatchelfHook];
    buildInputs = [];
    sourceRoot = ".";
  }
