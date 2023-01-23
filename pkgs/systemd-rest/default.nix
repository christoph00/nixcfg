{
  stdenv,
  lib,
  buildGoModule,
  fetchFromGitHub,
  makeWrapper,
  go,
  git,
  ...
}:
with lib;
  buildGoModule rec {
    pname = "systemd-rest";
    version = "0.1";

    src = fetchFromGitHub {
      owner = "christoph00";
      repo = pname;
      rev = "${version}";
      sha256 = "0a7w2qm80gj39c95sbd57lyq0dkyrdrrjmybbifjnr0jvbi6qqng";
    };

    ldflags = [
      "-s"
      "-w"
      "-extldflags '-static'"
    ];

    subPackages = ["."];

    vendorSha256 = lib.fakeSha256;
    #vendorSha256 = "sha256-+i6jUImDMrsDnIPjIp8uM2BR1IYMqWG1OmvA2w/AfVQ=";

    #doCheck = false;

    meta = {
      description = "A minimal HTTP REST interface for systemd.";
      homepage = "https://github.com/christoph00/systemd-rest";
      license = licenses.gpl3;
    };
  }
