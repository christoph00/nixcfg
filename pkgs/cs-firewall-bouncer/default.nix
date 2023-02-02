{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "cs-firewall-bouncer";
  version = "0.0.25";

  src = fetchFromGitHub {
    owner = "crowdsecurity";
    repo = "cs-firewall-bouncer";
    rev = "v${version}";
    hash = "sha256-evtx1f03aWaqeibiR9PP/OQfPlc7N16PrhaMRmGQEMI=";
  };

  vendorHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/crowdsecurity/crowdsec/pkg/cwversion.Version=v${version}"
    "-X github.com/crowdsecurity/crowdsec/pkg/cwversion.BuildDate=1970-01-01_00:00:00"
  ];

  subPackages = ["."];

  meta = with lib; {
    description = "Crowdsec bouncer written in golang for firewalls";
    homepage = "https://github.com/crowdsecurity/cs-firewall-bouncer";
    license = licenses.mit;
  };
}
