{
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation rec {
  pname = "ha-component-better-thermostat";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "KartoffelToby";
    repo = "better_thermostat";
    rev = version;
    sha256 = "009ajl7jwl3wsph78vc45lmjf43ipnzyfq0dx9w2a0ya6903n349";
  };

  installPhase = ''
    mkdir -p $out
    cp -r custom_components/better_thermostat $out/
  '';
}
