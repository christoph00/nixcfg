{
  pkgs,
  inputs,
}:
let
  name = "mcpo";
  version = "0.0.14";

  src = pkgs.fetchFromGitHub {
    owner = "open-webui";
    repo = "mcpo";
    rev = "refs/tags/v${version}";
    hash = "sha256-4VkOaR2nW6HTfxF24xiH9wC7r277XsSN12+W0759Fmg=";
  };
  uvEnv = inputs.uv2nix.mkEnv {
    inherit name;
    python = pkgs.python312;
    workspaceRoot = src;
    pyprojectOverrides = final: prev: { };
  };
in
pkgs.stdenv.mkDerivation {
  inherit version src;
  pname = name;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    ${pkgs.rsync}/bin/rsync -a --exclude='bin/' ${uvEnv}/ $out
    cp ${uvEnv}/bin/mcpo $out/bin/mcpo
    runHook postInstall
  '';
  meta = {
    changelog = "https://github.com/open-webui/mcpo/blob/main/CHANGELOG.md";
    description = "A simple, secure MCP-to-OpenAPI proxy server";
    homepage = "https://github.com/open-webui/mcpo";
    license = pkgs.lib.licenses.mit;
    mainProgram = "mcpo";
  };
}
