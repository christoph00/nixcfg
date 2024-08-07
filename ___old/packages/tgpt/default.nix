{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "tgpt";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "aandrew-me";
    repo = "tgpt";
    rev = "v${version}";
    hash = "sha256-83rSfzPJF3+EZP0vaTKpH2Zcnl5/0fnNW/G+9ctvvo4=";
  };

  vendorHash = "sha256-g8mfJmp27dyl/xOViprYF5p+XYWeKwKlZVw1/lNhWOU=";

  ldflags = [
    "-s"
    "-w"
  ];
  doCheck = false;

  meta = with lib; {
    description = "ChatGPT in terminal without needing API keys";
    homepage = "https://github.com/aandrew-me/tgpt";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [];
    mainProgram = "tgpt";
  };
}
