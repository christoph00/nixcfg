{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "olivetin";
  version = "2022.11.14";

  src = fetchFromGitHub {
    owner = "OliveTin";
    repo = "OliveTin";
    rev = version;
    hash = "sha256-3vl9S9pPrYdjewrzttoDU5xjCYG6XWAk5FlTN5w8hw0=";
  };

  vendorHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  subPackages = ["./cmd/OliveTin"];

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/var/www/olivetin
    install -m755 OliveTin $out/bin/
    mv webui/* $out/var/www/olivetin/
  '';

  meta = with lib; {
    description = "OliveTin gives safe and simple access to predefined shell commands from a web interface";
    homepage = "https://github.com/OliveTin/OliveTin";
    license = licenses.agpl3Only;
  };
}
