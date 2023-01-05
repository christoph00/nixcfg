{
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "ha-component-better-thermostat";
  version = "1.0.0-beta55";

  src = fetchFromGitHub {
    owner = "KartoffelToby";
    repo = "better_thermostat";
    rev = version;
    sha256 = "10fv3biv1b2x7cq3jn79j4k62c3v7j35521c11k4bxxf4nxpzjhy";
  };

  installPhase = ''
    mkdir -p $out
    cp -r custom_components/better_thermostat $out/
  '';
}
