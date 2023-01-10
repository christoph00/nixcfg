{
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation rec {
  pname = "ha-component-better-thermostat";
  version = "1.0.0-beta56";

  src = fetchFromGitHub {
    owner = "KartoffelToby";
    repo = "better_thermostat";
    rev = version;
    sha256 = "02922j7ymy0fczx1wdqwr158c3ddgmxf5jfyfyam4i1df0fvfq80";
  };

  installPhase = ''
    mkdir -p $out
    cp -r custom_components/better_thermostat $out/
  '';
}
