{ pkgs }:
pkgs.buildGoModule rec {
  pname = "altmount";
  version = "unstable-2025-12-17";

  src = pkgs.fetchFromGitHub {
    owner = "javi11";
    repo = "altmount";
    rev = "34a9a500a27d1b3e70122c858e39c02976765276";
    hash = "sha256-L6JOWbKUQu8mjT3cHp2ZtXd3svhmNqV+Cdi7eEqnirM=";
  };

  vendorHash = "sha256-CCxEW3YmGb+SfslxC7qDKfZr2ZREHUJ53cgDCzOzjpU=";

  subPackages = [ "cmd/altmount" ];
  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Usenet virtual fs";
    homepage = "https://github.com/javi11/altmount";
    license = pkgs.lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "altmount";
  };
}
