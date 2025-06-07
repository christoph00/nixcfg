{
  pkgs,
  ...
}:

pkgs.python3.pkgs.buildPythonApplication rec {
  pname = "vector-code";
  version = "0.6.11";
  pyproject = true;

  src = pkgs.fetchFromGitHub {
    owner = "Davidyz";
    repo = "VectorCode";
    rev = version;
    hash = "sha256-o+TTcY2DKoFcB5PJlVQ19xONd2+7q/ZpfieWtk5Q/xg=";
  };

  build-system = [
    pkgs.python3.pkgs.pdm-backend
  ];

  dependencies = with pkgs.python3.pkgs; [
    charset-normalizer
    chromadb
    colorlog
    httpx
    json5
    numpy
    pathspec
    psutil
    pygments
    sentence-transformers
    shtab
    tabulate
    transformers
    tree-sitter
    tree-sitter-language-pack
    wheel
  ];

  optional-dependencies = with pkgs.python3.pkgs; {
    intel = [
      openvino
      optimum
    ];
    legacy = [
      numpy
      torch
      transformers
    ];
    lsp = [
      lsprotocol
      pygls
    ];
    mcp = [
      mcp
      pydantic
    ];
  };

  pythonImportsCheck = [
    "vector_code"
  ];

  meta = {
    description = "A code repository indexing tool to supercharge your LLM experience";
    homepage = "https://github.com/Davidyz/VectorCode";
    license = pkgs.lib.licenses.mit;
    mainProgram = "vector-code";
  };
}
