{
  pkgs,
  pname,
  ...
}:

pkgs.buildGoModule rec {
  inherit pname;
  version = "0.28.0";

  src = pkgs.fetchFromGitHub {
    owner = "TBXark";
    repo = "mcp-proxy";
    rev = "v${version}";
    hash = "sha256-3W4ril9J1zRvXznU+4rCxFBRHGbjUZ1K6US4fRmyIH4=";
  };

  vendorHash = "sha256-0fE5X0yAnXeOlt6aM4O2LWASY8+81wwk86ssWwQjxGA=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "An MCP proxy server that aggregates and serves multiple MCP resource servers through a single HTTP server";
    homepage = "https://github.com/TBXark/mcp-proxy";
    license = pkgs.lib.licenses.mit;
    mainProgram = "mcp-proxy";
  };
}
