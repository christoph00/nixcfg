{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "crowdsec";
  version = "1.4.5";

  src = fetchFromGitHub {
    owner = "crowdsecurity";
    repo = "crowdsec";
    rev = "v${version}";
    hash = "sha256-Bmg7+087RBvxsI6gVw7c0WZnLVed77wSnoqSs2tAJZ0=";
  };

  vendorHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  nativeBuildInputs = [installShellFiles];

  subPackages = [
    "cmd/crowdsec"
    "cmd/crowdsec-cli"
  ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/crowdsecurity/crowdsec/pkg/cwversion.Version=v${version}"
    "-X github.com/crowdsecurity/crowdsec/pkg/cwversion.BuildDate=1970-01-01_00:00:00"
  ];

  postBuild = "mv $GOPATH/bin/{crowdsec-cli,cscli}";

  postInstall = ''
    mkdir -p $out/share/crowdsec
    cp -r ./config $out/share/crowdsec/
    installShellCompletion --cmd cscli \
      --bash <($out/bin/cscli completion bash) \
      --fish <($out/bin/cscli completion fish) \
      --zsh <($out/bin/cscli completion zsh)
  '';

  meta = with lib; {
    description = "CrowdSec - the open-source and participative IPS able to analyze visitor behavior & provide an adapted response to all kinds of attacks. It also leverages the crowd power to generate a global CTI database to protect the user network";
    homepage = "https://github.com/crowdsecurity/crowdsec";
    license = licenses.mit;
    maintainers = with maintainers; [];
  };
}
