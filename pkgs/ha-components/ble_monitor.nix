{
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation rec {
  pname = "ha-component-ble-monitor";
  version = "11.5.0";

  src = fetchFromGitHub {
    owner = "custom-components";
    repo = "ble_monitor";
    rev = version;
    sha256 = "0dqccinmvlji1jry0w5rnj1fffrykhq6pz4fm6c25lqqyr237s0a";
  };

  installPhase = ''
    mkdir -p $out
    cp -r custom_components/ble_monitor $out/
  '';
}
