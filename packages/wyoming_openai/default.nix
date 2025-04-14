{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "wyoming-openai";
  version = "unstable-2025-04-14";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "christoph00";
    repo = "wyoming_openai";
    rev = "64a7cd0a09d20bc727207b1cb5eae70f29700bcc";
    hash = "sha256-1npeRmBRQpBSrAxWWeS6lloLLnI0w/hqZUgY9CRYMnc=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  dependencies = with python3.pkgs; [
    anyio
    colorama
    distro
    httpx
    jiter
    openai
    pydantic
    tqdm
    typing-extensions
    wyoming
  ];

  pythonImportsCheck = [
    "wyoming_openai"
  ];

  meta = {
    description = "OpenAI-Compatible Proxy Middleware for the Wyoming Protocol";
    homepage = "https://github.com/christoph00/wyoming_openai";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "wyoming-openai";
  };
}
