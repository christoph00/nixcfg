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
      x86_64-linux = "linux-amd64";

      aarch64-linux = "linux-arm64";
    }
    .${system}
    or throwSystem;

  sha256 =
    {
      x86_64-linux = "sha256-7vviqktDhFTjFEjLEbgqcwUxyqRTvAUNNwta02pEz5E=";

      aarch64-linux = "011q852yycs61m3qvpwsbhfy0w5gx6qh2dwn4k16n1nq3k82s1z2";
    }
    .${system}
    or throwSystem;
in
  stdenv.mkDerivation rec {
    pname = "olivetin";
    version = "2022.11.14";
    src = fetchurl {
      name = "OliveTin-${version}-${plat}.tar.gz";

      url = "https://github.com/OliveTin/OliveTin/releases/download/${version}/OliveTin-${plat}.tar.gz";

      inherit sha256;
    };
    nativeBuildInputs = [autoPatchelfHook];
    buildInputs = [];
    sourceRoot = ".";
    installPhase = ''
      mkdir -p $out/bin
      install -m755 -D OliveTin-*/OliveTin $out/bin/olivetin
      mv OliveTin-*/webui $out/
    '';
  }
