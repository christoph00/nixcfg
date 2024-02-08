{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  python3Packages,
}:
buildHomeAssistantComponent rec {
  domain = "ollama_conversation";
  owner = "ej52";
  version = "1.0.2";

  src = fetchFromGitHub {
    inherit owner;
    repo = "hass-ollama-conversation";
    rev = "v${version}";
    sha256 = "0ll0212v988dj23r89kcskl7g7l8psxdzn8f2jjwjahnnb45hibk";
  };

  propagatedBuildInputs = with python3Packages; [
    colorlog
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
