{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
}:
buildHomeAssistantComponent rec {
  owner = "KartoffelToby";
  domain = "better_thermostat";
  version = "1.5.0-beta5";

  src = fetchFromGitHub {
    inherit owner;
    repo = domain;
    rev = version;
    sha256 = "1679ak9ipxbakscfzxpi6phz825xfyr24chbdi37ln8zry6k1w1y";
  };

  meta = with lib; {
    description = "This custom component for Home Assistant will add crucial features to your climate-controlling TRV (Thermostatic Radiator Valves) to save you the work of creating automations to make it smart. It combines a room-temperature sensor, window/door sensors, weather forecasts, or an ambient temperature probe to decide when it should call for heat and automatically calibrate your TRVs to fix the imprecise measurements taken in the radiator's vicinity";
    homepage = "https://github.com/KartoffelToby/better_thermostat";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [];
    mainProgram = "better-thermostat";
    platforms = platforms.all;
  };
}
