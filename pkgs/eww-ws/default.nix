{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "eww-ws";
  version = "unstable-2023-01-21";

  src = fetchFromGitHub {
    owner = "dlasky";
    repo = "eww-ws";
    rev = "4bd55a88b96b3640830dfa47c37e07b95f614d51";
    hash = "sha256-i3fvydiTepNkZuuEZ9GapRB0GpvFAcQgg6eucyQTy2o=";
  };

  vendorHash = "sha256-Ds78icxEE5DRlNJx8//ME5t3hP/FZQAHA4ZjVMK9h9Y=";

  ldflags = ["-s" "-w"];

  meta = with lib; {
    description = "A simple Daemon to provide workspace variables to EWW ( Elkowars Wacky Widgets";
    homepage = "https://github.com/dlasky/eww-ws";
    license = licenses.mit;
    maintainers = with maintainers; [];
  };
}
