{
  stdenvNoCC,
  fetchurl,
  unzip,
  ...
}:
stdenvNoCC.mkDerivation rec {
  pname = "AriaNg";
  version = "1.3.2";

  src = fetchurl {
    url =
      "https://github.com/mayswind/${pname}"
      + "/releases/download/${version}/${pname}-${version}-AllInOne.zip";
    hash = "sha256-Rxhxoe/1Nm1OXLw4S6VZ99RXxZ5ANegoVeTragDTHgs=";
  };
  nativeBuildInputs = [unzip];
  unpackPhase = "unzip ${src}";
  installPhase = "mkdir -p $out && cp * $_";
}
