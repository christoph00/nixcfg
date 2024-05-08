{
  lib,
  python3Packages,
  makeWrapper,
  writeShellScript,
  fetchFromGitHub,
}: let
  pname = "immich-ml";
  version = "1.103.1";
  src = fetchFromGitHub {
    owner = "immich-app";
    repo = "immich";
    rev = "v${version}";
    hash = "sha256-/NtL24C2eUeDDJjJ8jwlpqtEQOwqDkIxv8w2VMtD1yg=";
    fetchSubmodules = true;
  };
  pythonpkgs = python3Packages.override {
    overrides = self: super: {
      pydantic = python3Packages.pydantic_1;
    };
  };
  python = pythonpkgs.python;
in
  python.pkgs.buildPythonApplication rec {
    inherit pname src version;

    pyproject = true;

    sourceRoot = "${src.name}/machine-learning";

    nativeBuildInputs = with pythonpkgs; [
      poetry-core
      pythonRelaxDepsHook
      makeWrapper
    ];

    pythonRelaxDeps = [
      "setuptools"
    ];

    pythonRemoveDeps = ["opencv-python-headless" "python-multipart" "pydantic"];

    # dontWrapPythonPrograms = true;

    propagatedBuildInputs = with python.pkgs; [
      insightface
      opencv4
      pillow
      fastapi
      uvicorn
      aiocache
      rich
      ftfy
      setuptools
      multipart
      orjson
      gunicorn
      huggingface-hub
      tokenizers
    ];

    # No tests available
    doCheck = false;

    meta = with lib; {
      description = "High performance self-hosted photo and video management solution";
      homepage = "https://github.com/immich-app/immich";
      license = licenses.agpl3Only;
      maintainers = with maintainers; [];
      platforms = platforms.all;
    };
  }
