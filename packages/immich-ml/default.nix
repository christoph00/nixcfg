{
  lib,
  stdenv,
  python3,
  makeWrapper,
  writeShellScript,
  fetchFromGitHub,
}: let
  pname = "immich-ml";
  version = "1.105.1";
  src = fetchFromGitHub {
    owner = "immich-app";
    repo = "immich";
    rev = "v${version}";
    hash = "sha256-94OPpruPaj1+6nswWoDnG//FI0R1TMf8sF9VAYnvDM0=";

    fetchSubmodules = true;
  };
  python = python3.override {
    packageOverrides = self: super: {
      pydantic = super.pydantic_1;

      versioningit = super.versioningit.overridePythonAttrs {
        # checkPhase requires pydantic>=2
        doCheck = false;
      };

      albumentations = super.albumentations.overridePythonAttrs {
        doCheck = false;
      };
    };
  };
  ann = stdenv.mkDerivation {
    inherit version src;
    pname = "${pname}-ann";
    sourceRoot = "${src.name}/machine-learning/ann";

    # buildPhase = ''
    #   g++ -shared -O3 -o libann.so -fuse-ld=gold -std=c++17 -larmnn -larmnnDeserializer -larmnnTfLiteParser -larmnnOnnxParser  ann.cpp
    # '';

    dontBuild = true;

    installPhase = ''
       mkdir -p "$out"/ann
      # cp libann.so "$out/ann"
      # cp export "$out/ann"
       cp *.py "$out/ann"
    '';
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

    pythonRemoveDeps = ["opencv-python-headless" "pydantic" "fastapi-slim"];

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
      python-multipart
      orjson
      gunicorn
      huggingface-hub
      tokenizers
    ];

    # No tests available
    doCheck = false;

    postInstall = let
      start_script = writeShellScript "start-immich-ml" ''
        ${lib.getExe python.pkgs.gunicorn} "$@" -k app.config.CustomUvicornWorker -w 1 -b 0.0.0.0:3003 -t 120 app.main:app;
      '';
    in ''
      rm -f $out/bin/*

      cp -r ${ann}/ann $out/${python.sitePackages}/

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
