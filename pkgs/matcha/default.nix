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
    pname = "matcha";
    version = "0.4.1";

    src = fetchFromGitHub {
      owner = "piqoni";
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

    #vendorSha256 = lib.fakeSha256;
    vendorSha256 = "sha256-3LgCIC1/5uThPJAEPoLqfhPW6qVFZc/TlkKxawTpbyk=";

    doCheck = false;

    meta = {
      description = "Matcha is a daily digest generator for your RSS feeds";
      homepage = "https://github.com/piqoni/matcha";
      license = licenses.mit;
    };
  }
