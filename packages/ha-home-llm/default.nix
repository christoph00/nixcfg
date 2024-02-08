{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
}:
buildHomeAssistantComponent rec {
  domain = "home-llm";
  owner = "acon96";
  version = "0.2.5";

  src = fetchFromGitHub {
    inherit owner;
    repo = domain;
    rev = "v${version}";
    hash = "sha256-ULIxdQKoe8+OlxWeUxh34r+L1KvmgHqi1S3mqjxoxng=";
  };

  meta = with lib; {
    description = "A Home Assistant integration that allows you to control your house using an LLM running locally";
    homepage = "https://github.com/acon96/home-llm";
    license = licenses.mit;
    maintainers = with maintainers; [];
    mainProgram = "ha-home-llm";
    platforms = platforms.all;
  };
}
