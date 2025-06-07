{
  pkgs,
  ...
}:

pkgs.python3.pkgs.buildPythonApplication rec {
  pname = "basic-memory";
  version = "0.13.0b5";
  pyproject = true;

  src = pkgs.fetchFromGitHub {
    owner = "basicmachines-co";
    repo = "basic-memory";
    rev = "v${version}";
    hash = "sha256-OCY5xHwjaNMuhHAj1GDRtO1GtHjjIzZwOQkZ8TsiMBI=";
  };

  build-system = [
    pkgs.python3.pkgs.hatchling
    pkgs.python3.pkgs.uv-dynamic-versioning
  ];

  nativeBuildInputs = [ pkgs.python3.pkgs.pythonRelaxDepsHook ];

  pythonRemoveDeps = [
    "pyright"
  ];

  dependencies = with pkgs.python3.pkgs; [
    aiosqlite
    alembic
    dateparser
    fastapi
    fastmcp
    greenlet
    icecream
    loguru
    markdown-it-py
    mcp
    pillow
    pybars3
    pydantic
    pydantic-settings
    pyjwt
    pytest-aio
    python-dotenv
    python-frontmatter
    pyyaml
    rich
    sqlalchemy
    typer
    unidecode
    watchfiles
  ];
  nativeCheckInputs = [ pkgs.pyright ];

  doCheck = false;
  dontCheck = true;
  doInstallCheck = false;
  pythonImportsCheck = [ ];

  meta = {
    description = "Basic Memory is a knowledge management system that allows you to build a persistent semantic graph from conversations with AI assistants, stored in standard Markdown files on your computer. Integrates directly with Obsidan.md";
    homepage = "https://github.com/basicmachines-co/basic-memory";
    changelog = "https://github.com/basicmachines-co/basic-memory/blob/${src.rev}/CHANGELOG.md";
    license = pkgs.lib.licenses.agpl3Only;
    mainProgram = "basic-memory";
  };
}
