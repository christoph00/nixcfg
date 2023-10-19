{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation rec {
  pname = "ha-better-thermostat";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "KartoffelToby";
    repo = "better_thermostat";
    rev = version;
    hash = "sha256-QgaW/VGENC2r9pAUvuTSCA9s3dEEkoJYL60PVrtiyDw=";
  };

  installPhase = ''
    mkdir -p $out
    cp -r custom_components/better_thermostat $out/
  '';

  meta = with lib; {
    description = "This custom component for Home Assistant will add crucial features to your climate-controlling TRV (Thermostatic Radiator Valves) to save you the work of creating automations to make it smart. It combines a room-temperature sensor, window/door sensors, weather forecasts, or an ambient temperature probe to decide when it should call for heat and automatically calibrate your TRVs to fix the imprecise measurements taken in the radiator's vicinity";
    homepage = "https://github.com/KartoffelToby/better_thermostat";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [];
    mainProgram = "better-thermostat";
    platforms = platforms.all;
  };
}
