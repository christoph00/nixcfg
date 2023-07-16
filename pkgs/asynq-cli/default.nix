{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "asynq-cli";
  version = "0.24.1";

  src =
    fetchFromGitHub {
      owner = "hibiken";
      repo = "asynq";
      rev = "v${version}";
      hash = "sha256-YDNb11Aei76kM4N40YYUkchAy7PGMAbx1GXpx7hJZBE=";
    }
    + "/tools";

  vendorHash = "sha256-YYAiq0Pt1R17feIyi6RP64dhSyFJSMRKFE0g9dWQAfc=";

  ldflags = ["-s" "-w"];

  proxyVendor = true;

  subPackages = ["asynq"];

  meta = with lib; {
    description = "Simple, reliable, and efficient distributed task queue in Go";
    homepage = "https://github.com/hibiken/asynq";
    changelog = "https://github.com/hibiken/asynq/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [];
  };
}
