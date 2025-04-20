{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  versionCheckHook,
}:

buildNpmPackage rec {
  pname = "open-codex";
  version = "unstable-2025-04-19";

  src = fetchFromGitHub {
    owner = "ymichael";
    repo = "open-codex";
    rev = "752064e52350d69089ec4a1c0e734080f983b64c";
    hash = "sha256-Zw/kKPxGQAqKwsPV+PnSkjqCtVJ+dsrLzzHatGm/T5I=";
  };

  sourceRoot = "${src.name}/codex-cli";

  npmDepsHash = "sha256-riVXC7T9zgUBUazH5Wq7+MjU1FepLkp9kHLSq+ZVqbs=";

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  meta = {
    description = "Lightweight coding agent that runs in your terminal";
    homepage = "https://github.com/ymichael/open-codex";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "open-codex";
    platforms = lib.platforms.all;
  };
}
