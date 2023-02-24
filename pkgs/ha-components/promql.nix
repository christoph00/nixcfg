{
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation rec {
  pname = "ha-component-promql";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "christoph00";
    repo = "home-assistant-promql";
    rev = "v${version}";
    sha256 = "1abdsyqf70vkwqid47wcl64hcl1z6r7r61hz8q6k5m6vyvnzzygz";
  };

  installPhase = ''
    mkdir -p $out
    cp -r custom_components/promql $out/
  '';
}
