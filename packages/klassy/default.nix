{ mkDerivation
, lib
, fetchFromGitHub
, cmake
, extra-cmake-modules
, kdecoration
, plasma-workspace
, qtbase
, qt5
}:

mkDerivation rec {
  pname = "klassy";
  version = "4.3.breeze5.27.5";

  src = fetchFromGitHub {
    owner = "paulmcauley";
    repo = pname;
    rev = version;
    sha256 = "10h17dzbcmvf5f8ynsc8v1zsl9mk4c5kxf7zc7slgrnlpv83gays";
  };

  extraCmakeFlags = [ "-DBUILD_TESTING=OFF" ];


   buildInputs = [
    kdecoration
    plasma-workspace
    qtbase
    qt5.qtx11extras
  ];

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
  ];

  meta = with lib; {
    description = "A highly customizable binary Window Decoration and Application Style plugin for recent versions of the KDE Plasma desktop";
    homepage = "https://github.com/paulmcauley/klassy";
    license = with licenses; [ gpl2Only gpl2Plus gpl3Only bsd3 mit ];
  };
}
