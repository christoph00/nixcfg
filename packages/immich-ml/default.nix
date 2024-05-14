{
  lib,
  python3,
  makeWrapper,
  writeShellScript,
  fetchFromGitHub,
}: let
  pname = "immich-ml";
  version = "1.105.0";
  src = fetchFromGitHub {
    owner = "immich-app";
    repo = "immich";
    rev = "v${version}";
    hash = "sha256-xHRAxPC7juO4g4f2TvNC87p8YnzcjPS2Vn3wP7NSTi8=";
    fetchSubmodules = true;
  };
  python = python3.override {
    packageOverrides = self: super: {
      pydantic = super.pydantic_1;

      versioningit = super.versioningit.overridePythonAttrs {
        # checkPhase requires pydantic>=2
        doCheck = false;
      };
    };
  };
in
  python.pkgs.buildPythonApplication rec {
    inherit pname src version;

    pyproject = true;

    sourceRoot = "${src.name}/machine-learning";

    nativeBuildInputs = with python.pkgs; [
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

    postInstall = let
      start_script = writeShellScript "start-immich-ml" ''
        ${lib.getExe python.pkgs.gunicorn} "$@" -k app.config.CustomUvicornWorker app.main:app;
      '';
    in ''
      rm -f $out/bin/*

      makeWrapper ${start_script} $out/bin/immich-ml \
        --set PYTHONPATH "$out/${python.sitePackages}:${python.pkgs.makePythonPath propagatedBuildInputs}"
    '';

    meta = with lib; {
      description = "High performance self-hosted photo and video management solution";
      homepage = "https://github.com/immich-app/immich";
      license = licenses.agpl3Only;
      maintainers = with maintainers; [];
      platforms = platforms.all;
    };
  }
