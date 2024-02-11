{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "dunnart";
  version = "unstable-2023-11-08";

  src = fetchFromGitHub {
    owner = "warthog618";
    repo = "dunnart";
    rev = "5d6f457ea0bce587f18bc2dd354efaa0703c19f2";
    hash = "sha256-MIeHyhHeKPPlaamSyRhSvEsIKcVjnuSUFSZH1E3oNJk=";
  };

  vendorHash = "sha256-vpm8uTjazUfrjwwGXiP2UP5nJu0Vfl8Z+T1gsKefmDo=";

  ldflags = ["-s" "-w"];

  meta = with lib; {
    description = "Lightweight remote system monitoring over MQTT for Home Assistant";
    homepage = "https://github.com/warthog618/dunnart";
    license = licenses.mit;
    maintainers = with maintainers; [];
    mainProgram = "dunnart";
  };
}
