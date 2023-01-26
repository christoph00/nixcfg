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
    sha256 = "11qwgj0ndhiyl8yx43v0wz60km1gh5q0hcm8ydnj100gilan25vq";
  };

  phases = ["installPhase"];
  installPhase = ''
    outdir=$out/share/AriaNg
    mkdir -p $outdir
    cp -r $src/* $outdir/
  '';
}
