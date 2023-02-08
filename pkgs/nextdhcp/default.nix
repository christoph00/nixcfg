{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "nextdhcp";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "nextdhcp";
    repo = "nextdhcp";
    rev = "v${version}";
    hash = "sha256-73i43LkJjm+Sf1E7LwIE1cMOPlAeOMWx+32vVhl5lT0=";
  };

  vendorHash = "sha256-Ox+aV09YH9zuWULExx7bYU1+SpBw1XsuVU6Bav2ZVsQ=";

  meta = with lib; {
    description = "A DHCP server chaining middlewares. Similar to CoreDNS and Caddy";
    homepage = "https://github.com/nextdhcp/nextdhcp";
    license = licenses.mit;
  };
}
