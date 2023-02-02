{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "media-sort";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "christoph00";
    repo = "media-sort";
    rev = "v${version}";
    hash = "sha256-hP1rbG5+x6DUgQslurZzLNCbm+CUazclRcLwJULH2qQ=";
  };

  vendorHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  ldflags = [
    "-s"
    "-w"
  ];

  subPackages = ["."];

  meta = with lib; {
    description = "Automatically organise your movies and tv series";
    homepage = "https://github.com/christoph00/media-sort";
    license = licenses.mit;
  };
}
