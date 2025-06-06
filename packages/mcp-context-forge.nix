{
  pkgs,
  pname,
  ...
}:

pkgs.python3.pkgs.buildPythonApplication rec {
  inherit pname;
  version = "0.1.0";
  pyproject = true;

  src = pkgs.fetchFromGitHub {
    owner = "IBM";
    repo = "mcp-context-forge";
    rev = "v${version}";
    hash = "sha256-shJYpzRK5RQXNOBKYNrBImHvLRsjXR2p9CXmc/wSkdU=";
  };

  build-system = [
    pkgs.python3.pkgs.setuptools
    pkgs.python3.pkgs.wheel
  ];

  pythonRelaxDeps = true;
  nativeBuildInputs = [
    pkgs.python3.pkgs.pythonRelaxDepsHook
  ];

  dependencies = with pkgs.python3.pkgs; [
    cryptography
    fastapi
    gunicorn
    httpx
    jinja2
    jq
    jsonpath-ng
    jsonschema
    mcp
    parse
    psutil
    pydantic
    pydantic-settings
    pyjwt
    sqlalchemy
    sse-starlette
    starlette
    uvicorn
    zeroconf
  ];

  optional-dependencies = with pkgs.python3.pkgs; {
    all = [
      mcpgateway
    ];
    dev = [
      argparse-manpage
      autoflake
      bandit
      black
      bump2version
      check-manifest
      code2flow
      cookiecutter
      coverage
      coverage-badge
      darglint
      fawltydeps
      flake8
      gprof2dot
      importchecker
      isort
      mypy
      pexpect
      pip-audit
      pip-licenses
      pre-commit
      pydocstyle
      pylint
      pylint-pydantic
      pyre-check
      pyright
      pyroma
      pyspelling
      pytest
      pytest-asyncio
      pytest-cov
      pytest-examples
      pytest-md-report
      pytest-rerunfailures
      pytest-xdist
      pytype
      radon
      ruff
      settings-doc
      snakeviz
      tomlcheck
      twine
      ty
      types-tabulate
    ];
    dev-all = [
      mcpgateway
    ];
    postgres = [
      psycopg2-binary
    ];
    redis = [
      redis
    ];
  };

  pythonImportsCheck = [
    "mcpgateway"
  ];

  meta = {
    description = "A Model Context Protocol (MCP) Gateway. Serves as a central management point for tools, resources, and prompts that can be accessed by MCP-compatible LLM applications. Converts REST API endpoints to MCP, composes virtual MCP servers with added security and observability, and converts between protocols (stdio, SSE";
    homepage = "https://github.com/IBM/mcp-context-forge";
    changelog = "https://github.com/IBM/mcp-context-forge/blob/${src.rev}/CHANGELOG.md";
    license = pkgs.lib.licenses.asl20;
    mainProgram = "mcp-context-forge";
  };
}
