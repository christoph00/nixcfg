{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "go-vod";
  version = "0.1.7";

  src = fetchFromGitHub {
    owner = "pulsejet";
    repo = "go-vod";
    rev = version;
    hash = "sha256-qMEYa+aeFeKyh2OatscB1Yl7LZrD+t2hmPwL3tIP7t0=";
  };

  vendorHash = null;

  ldflags = ["-s" "-w"];

  meta = with lib; {
    description = "Zero-dependency HLS VOD server in go";
    homepage = "https://github.com/pulsejet/go-vod";
    license = licenses.asl20;
    maintainers = with maintainers; [];
  };
}
