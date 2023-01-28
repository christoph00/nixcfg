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
    pname = "piqoni";
    version = "0.4.1";

    src = fetchFromGitHub {
      owner = "drakkan";
      repo = pname;
      rev = "v${version}";
      sha256 = "0chhcgam7x9v3c3f1crab41dlrhhy3li3vqmfzvzig0ygmmh7q0z";
    };

    ldflags = [
      "-s"
      "-w"
      "-extldflags '-static'"
    ];

    #proxyVendor = false;

    subPackages = ["."];

    vendorSha256 = lib.fakeSha256;
    #vendorSha256 = "sha256-+i6jUImDMrsDnIPjIp8uM2BR1IYMqWG1OmvA2w/AfVQ=";

    doCheck = false;

    meta = {
      description = "Matcha is a daily digest generator for your RSS feeds";
      homepage = "https://github.com/piqoni/matcha";
      license = licenses.mit;
    };
  }
