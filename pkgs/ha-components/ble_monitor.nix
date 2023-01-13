{
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation rec {
  pname = "ha-component-ble-monitor";
  version = "11.3.1";

  src = fetchFromGitHub {
    owner = "custom-components";
    repo = "ble_monitor";
    rev = version;
    sha256 = "1npdm20as9pv8r2sims5akmlvni7mhaalj8psas334zsj68j2rra";
  };

  installPhase = ''
    mkdir -p $out
    cp -r custom_components/ble_monitor $out/
  '';
}
