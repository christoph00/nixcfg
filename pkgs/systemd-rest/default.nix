{
  stdenv,
  lib,
  buildGoModule,
  fetchFromGitHub,
  systemd,
  ...
}:
with lib;
  buildGoModule rec {
    pname = "systemd-rest";
    version = "1.0.1";

    src = fetchFromGitHub {
      owner = "christoph00";
      repo = pname;
      rev = "v${version}";
      sha256 = "1d85lnffi6klxf02caq25zq8g98p7m9kn6hwl34wpqb23c8kzqdn";
    };

    buildInputs = [systemd];

    #ldflags = [
    #  "-s"
    #  "-w"
    #  "-extldflags '-static'"
    #];

    CGO_ENABLED = 1;

    subPackages = ["./cmd/systemd-rest"];

    #vendorSha256 = lib.fakeSha256;
    vendorSha256 = "sha256-44TbwYX1QGwGUjnL9TY8DKqZNNAI9A+CptoH1xtV7No=";

    doCheck = false;

    #buildPhase = ''
    #  go build -o systemd-rest ./cmd/systemd-rest
    #'';

    installPhase = ''
      install -Dm755 systemd-rest -t $out/bin/systemd-rest
    '';

    meta = {
      description = "A minimal HTTP REST interface for systemd.";
      homepage = "https://github.com/christoph00/systemd-rest";
      license = licenses.gpl3;
    };
  }
