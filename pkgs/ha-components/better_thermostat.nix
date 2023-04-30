{
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation rec {
  pname = "ha-component-better-thermostat";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "KartoffelToby";
    repo = "better_thermostat";
    rev = version;
    sha256 = "1x2g7zzsfg565vvn1kja4x8wpbqxas45w9g5f5caj6iq9d99slkv";
  };

  installPhase = ''
    mkdir -p $out
    cp -r custom_components/better_thermostat $out/
  '';
}
