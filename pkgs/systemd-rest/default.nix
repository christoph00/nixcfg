{
  stdenv,
  lib,
  buildGoModule,
  fetchFromGitHub,
  ...
}:
with lib;
  buildGoModule rec {
    pname = "systemd-rest";
    version = "1.0.0";

    src = fetchFromGitHub {
      owner = "christoph00";
      repo = pname;
      rev = "v${version}";
      sha256 = "1x9js5syyrw4arr4g8y63mjjn0f4mlss31crng53dyfcaa50fbn0";
    };

    ldflags = [
      "-s"
      "-w"
      "-extldflags '-static'"
    ];

    subPackages = ["."];

    #vendorSha256 = lib.fakeSha256;
    vendorSha256 = "sha256-qQ3QrbeHgnYFHSwGjDkviIf2Nj+fZQsYr91yTfzOcMA=";

    #doCheck = false;

    meta = {
      description = "A minimal HTTP REST interface for systemd.";
      homepage = "https://github.com/christoph00/systemd-rest";
      license = licenses.gpl3;
    };
  }
