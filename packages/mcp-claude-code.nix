{
  pkgs,
  pname,
  ...
}:

pkgs.python3.pkgs.buildPythonApplication rec {
  inherit pname;
  version = "0.3.4";
  pyproject = true;

  src = pkgs.fetchFromGitHub {
    owner = "SDGLBL";
    repo = "mcp-claude-code";
    rev = "v${version}";
    hash = "sha256-GlBuzmb4mzWzw0HcGAjsk1XRCeR1COc124FuUCQQBNw=";
  };

  build-system = [
    pkgs.python3.pkgs.setuptools
    pkgs.python3.pkgs.wheel
  ];

  dependencies = with pkgs.python3.pkgs; [
    fastmcp
    gitpython
    grep-ast
    httpx
    litellm
    openai
    python-dotenv
    uvicorn
  ];

  optional-dependencies = with pkgs.python3.pkgs; {
    dev = [
      black
      pytest
      pytest-cov
      ruff
    ];
    performance = [
      orjson
      ujson
    ];
    test = [
      pytest
      pytest-asyncio
      pytest-cov
      pytest-mock
      twisted
    ];
  };

  pythonImportsCheck = [
    "mcp_claude_code"
  ];

  meta = {
    description = "MCP implementation of Claude Code capabilities and more";
    homepage = "https://github.com/SDGLBL/mcp-claude-code";
    changelog = "https://github.com/SDGLBL/mcp-claude-code/blob/${src.rev}/CHANGELOG.md";
    license = pkgs.lib.licenses.mit;
    mainProgram = "mcp-claude-code";
  };
}
