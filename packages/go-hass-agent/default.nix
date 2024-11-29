{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "go-hass-agent";
  version = "10.5.1";

  src = fetchFromGitHub {
    owner = "joshuar";
    repo = "go-hass-agent";
    rev = "v${version}";
    hash = "sha256-6uhwqfuIZ4rdp1tKBWUtylmS7Sp2+v7ll3Bh3vl1Pig=";
  };

  vendorHash = "sha256-kzmnfHIPwS2S85t9bIdMnSMY83uY7ccj6UQF5VIT3Mc=";

  ldflags = [ "-s" "-w" ];

  meta = {
    description = "A Home Assistant, native app for desktop/laptop devices";
    homepage = "https://github.com/joshuar/go-hass-agent";
    changelog = "https://github.com/joshuar/go-hass-agent/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "go-hass-agent";
  };
}
