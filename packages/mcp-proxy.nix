{
  pkgs,
  pname,
  ...
}:

pkgs.buildGoModule rec {
  inherit pname;
  version = "0.32.0";

  src = pkgs.fetchFromGitHub {
    owner = "TBXark";
    repo = "mcp-proxy";
    rev = "v${version}";
    hash = "sha256-2nsQ3nbLauWgX7jsg2kNyaF3w3VaOn2Ax2PSU3DRThk=";
  };

  vendorHash = "sha256-w2LCSRpadSEaOQc2HPFXR3Kw0o8OoNYyhJHSa9QElJs=";

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
