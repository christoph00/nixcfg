{
  pkgs,
  pname,
}:
let
  srcs = {
    aarch64-linux = {
      suffix = "linux-arm64";
      hash = "sha256-muDImiDqNZb1Ak2e1JC29vuSvHD32cBiTdSB1SsHY8k=";
    };
    x86_64-linux = {
      suffix = "linux-amd64";
      hash = "sha256-muDImiDqNZb1Ak2e1JC29vuSvHD32cBiTdSB1SsHY7k=";
    };
  };
  sysSrc =
    srcs.${pkgs.stdenv.hostPlatform.system}
      or (throw "Unsupported system: ${pkgs.stdenv.hostPlatform.system}");

in

pkgs.stdenv.mkDerivation rec {
  version = "0.5.1";
  inherit pname;

  src = pkgs.fetchurl {
    url = "https://github.com/agentgateway/agentgateway/releases/download/v${version}/agentgateway-${sysSrc.suffix}";
    hash = sysSrc.hash;
  };

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;
  dontUnpack = true;

  nativeBuildInputs = [
    pkgs.autoPatchelfHook
  ];

  installPhase = ''
    runHook preInstall

    install -m755 -D $src $out/bin/agentgateway

    runHook postInstall
  '';

  meta = {
    description = "Next Generation Agentic Proxy";
    homepage = "https://github.com/agentgateway/agentgateway";
    license = pkgs.lib.licenses.asl20;
    mainProgram = "agentgateway";
  };
}
