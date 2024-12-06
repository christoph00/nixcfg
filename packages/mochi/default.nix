{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "mochi";
  version = "2.6.6";

  src = fetchFromGitHub {
    owner = "mochi-mqtt";
    repo = "server";
    rev = "v${version}";
    hash = "sha256-F/YfoGzDG16CQv7QFwMs4ILpuIrA5BBtmzQsKSnvgjY=";
  };

  vendorHash = "sha256-+28spfekUVTDCvDgmKXpHNRQNAlQ4k9lEU4H6gZu9ZI=";

  ldflags = [
    "-s"
    "-w"
  ];

  postInstall = ''
    mv $out/bin/{cmd,mochi}
    rm $out/bin/docker
  '';

  meta = {
    description = "The fully compliant, embeddable high-performance Go MQTT v5 server for IoT, smarthome, and pubsub";
    homepage = "https://github.com/mochi-mqtt/server";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "mochi";
  };
}
