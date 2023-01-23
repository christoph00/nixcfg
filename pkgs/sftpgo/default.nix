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
      sha256 = "14iyh1clgs3ycs16lmlccyy7nyxzvvjsf8ir44fbm8nmij4hi3kc";
    };

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

    #vendorSha256 = lib.fakeSha256;
    vendorSha256 = "sha256-+i6jUImDMrsDnIPjIp8uM2BR1IYMqWG1OmvA2w/AfVQ=";

    doCheck = false;

    meta = {
      description = "Fully featured and highly configurable SFTP server.";
      homepage = "https://github.com/drakkan/sftpgo";
      license = licenses.agpl3;
    };
  }
