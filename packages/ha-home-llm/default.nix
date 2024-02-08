{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  python3Packages,
}:
buildHomeAssistantComponent rec {
  domain = "llama_conversation";
  owner = "acon96";
  version = "0.2.5";

  src = fetchFromGitHub {
    inherit owner;
    repo = "home-llm";
    rev = "v${version}";
    hash = "sha256-ULIxdQKoe8+OlxWeUxh34r+L1KvmgHqi1S3mqjxoxng=";
  };

  propagatedBuildInputs = with python3Packages; [
    huggingface-hub
    requests
  ];

  meta = with lib; {
    description = "A Home Assistant integration that allows you to control your house using an LLM running locally";
    homepage = "https://github.com/acon96/home-llm";
    license = licenses.mit;
    maintainers = with maintainers; [];
    mainProgram = "ha-home-llm";
    platforms = platforms.all;
  };
}
