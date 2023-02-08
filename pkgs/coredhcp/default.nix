{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule {
  pname = "coredhcp";
  version = "unstable-2022-12-15";

  src = fetchFromGitHub {
    owner = "spr-networks";
    repo = "coredhcp";
    rev = "103310208bb6b61f0d157a2ee505e413c7d21eba";
    hash = "sha256-DYlGoL+Vtu/NhqYzPiMIBh7Ed2rnegpW+mKBm21B9LY=";
  };

  vendorHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  subPackages = ["./cmds/coredhcp" "./cmds/exdhcp/dhclient"];

  meta = with lib; {
    description = "";
    homepage = "https://github.com/spr-networks/coredhcp";
    license = licenses.mit;
  };
}
