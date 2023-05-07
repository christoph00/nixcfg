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
    pname = "sftpgo";
    version = "2.4.4";

    src = fetchFromGitHub {
      owner = "drakkan";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-UL/CSNRvT9e+WAmE7nwd/EU7YOJ1mwMSnOIrd0dQJrk=";
    };

    vendorHash = "sha256-q6GgaMlmBPjovCpLku9/ENlEc0lF8gck1fM+fpptti4=";

    ldflags = [
      "-s"
      "-w"
      "-extldflags '-static'"
      "-X github.com/drakkan/sftpgo/v2/internal/version.commit=${src.rev}"
      "-X github.com/drakkan/sftpgo/v2/internal/version.date=1970-01-01T00:00:00Z"
    ];
    tags = ["nopgxregisterdefaulttypes" "bundle" "nosqlite"];

    #proxyVendor = false;

    #allowGoReference = true;

    subPackages = ["."];

    preBuildPhases = ["cpBundle"];
    cpBundle = "cp -r {openapi,static,templates} internal/bundle/";

    doCheck = false;

    meta = {
      description = "Fully featured and highly configurable SFTP server.";
      homepage = "https://github.com/drakkan/sftpgo";
      license = licenses.agpl3;
    };
  }
