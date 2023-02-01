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
    version = "2.4.2";

    src = fetchFromGitHub {
      owner = "drakkan";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-cSA7ndpIV3VvIZTBa9NCIlJn57EtT1qxrB0UsMENUS0=";
    };

    vendorHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

    ldflags = [
      "-s"
      "-w"
      "-extldflags '-static'"
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
