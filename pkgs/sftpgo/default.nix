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
      hash = "sha256-gB3r7Q4M4pXHB9cfCRU8hMccWaJ170es0CJfbo/7lsg=";
    };

    vendorHash = "sha256-og3mn0iYl6aubcSAUohqG4ZSqdBB4AQYZtpKfbp7kcQ=";

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
