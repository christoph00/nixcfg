{ lib
, buildGoModule
}:

buildGoModule rec {
  pname = "mqtt-host-agent";
  version = "1.0.0";

  src = ./.;

  vendorHash = "sha256-MI4E/GD3ExJgOKLzgK8+8YuCAxwZHI/GVOsL1rhsG9c=";

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];




  meta = with lib; {
    description = "MQTT Host Agent for managing systemd services and commands via MQTT";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
