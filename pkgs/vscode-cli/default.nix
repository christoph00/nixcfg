{
  pkgs,
  stdenvNoCC,
  autoPatchelfHook,
  fetchurl,
  buildFHSUserEnv,
  stdenv,
  ...
}: let
  inherit (stdenv.hostPlatform) system;

  throwSystem = throw "Unsupported system: ${system}";

  version = "1.74.2";
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

  vscode-cli-unwrapped = stdenvNoCC.mkDerivation {
    pname = "vscode-cli-unwrapped";
    inherit version;
    src = fetchurl {
      name = "VSCode-CLI_${version}_${plat}.tar..gz";
      url = "https://update.code.visualstudio.com/${version}/${plat}/stable";

      inherit hash;
    };
    #nativeBuildInputs = [autoPatchelfHook];
    #buildInputs = [];
    sourceRoot = ".";
    installPhase = ''install -m755 -D code $out/bin/code-cli '';
  };

  env = buildFHSUserEnv {
    name = "vscode-cli-${version}";
    targetPkgs = _: [vscode-cli-unwrapped];
    runScript = "vscode-cli";
  };
in
  stdenvNoCC.mkDerivation {
    pname = "vscode-cli";
    inherit version;

    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      mkdir -p $out/bin
      ln -s ${env}/bin/* $out/bin/vscode-cli
    '';
  }
