{
  lib,
  buildGoModule,
}:

buildGoModule rec {
  pname = "project-export";
  version = "1.0";
  src = ./.;

  vendorHash = null;

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  meta = with lib; {
    description = "Project codebase processor (single-file) with Laravel Support";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
