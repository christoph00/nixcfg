{
  pkgs,
  pname,
}:

pkgs.python3.pkgs.buildPythonApplication rec {
  inherit pname;
  version = "0.8.0";
  pyproject = true;

  src = pkgs.fetchFromGitHub {
    owner = "sparfenyuk";
    repo = "mcp-proxy";
    rev = "v${version}";
    hash = "sha256-3KGBQyiI6hbDfl37lhhnGYHixHYGsKAgTJH/PSe3UFs=";
  };
  build-system = [
    pkgs.python3.pkgs.setuptools
  ];

  dependencies = with pkgs.python3.pkgs; [
    mcp
    uvicorn
  ];

  pythonImportsCheck = [
    "mcp_proxy"
  ];

  meta = {
    description = "A bridge between Streamable HTTP and stdio MCP transports";
    homepage = "https://github.com/sparfenyuk/mcp-proxy";
    license = pkgs.lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "mcp-proxy";
  };
}
