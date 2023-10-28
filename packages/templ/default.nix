{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "templ";
  version = "0.2.408";

  src = fetchFromGitHub {
    owner = "a-h";
    repo = "templ";
    rev = "v${version}";
    hash = "sha256-IZJ3PrRJu9r76StXMh8Hw3xR3Gs7O4Ly86Jkzkgjppw=";
  };

  vendorHash = "sha256-7QYF8BvLpTcDstkLWxR0BgBP0NUlJ20IqW/nNqMSBn4=";

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/a-h/templ.Version=${version}"
  ];

  meta = with lib; {
    description = "A language for writing HTML user interfaces in Go";
    homepage = "https://github.com/a-h/templ";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "templ";
  };
}
