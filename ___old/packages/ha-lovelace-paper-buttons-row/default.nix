{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "ha-lovelace-paper-buttons-row";
  version = "2.1.3";

  src = fetchurl {
    url = "https://github.com/jcwillox/lovelace-paper-buttons-row/releases/download/${version}/paper-buttons-row.js";
    sha256 = "003zcj60sg0w5q26hbkj9jsfz7vfa0fkrzrrpkavb5pmqxsn3rpx";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir $out
    cp $src $out/paper-buttons-row.js
  '';

  meta = with lib; {
    description = "Adds highly configurable buttons that use actions and per-state styling";
    homepage = "https://github.com/jcwillox/lovelace-paper-buttons-row";
    license = licenses.mit;
    maintainers = with maintainers; [];
    platforms = platforms.all;
  };
}
