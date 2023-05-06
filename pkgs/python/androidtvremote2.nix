{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  aiofiles,
  cryptography,
  protobuf,
}:
buildPythonPackage rec {
  pname = "androidtvremote2";
  version = "0.0.8";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-JHEyyJigU3SYPE4KjI7eBbsgddjdMxcj5VvUPuH0sgM=";
  };

  nativeBuildInputs = [
    setuptools
  ];

  propagatedBuildInputs = [
    aiofiles
    cryptography
    protobuf
  ];

  pythonImportsCheck = ["androidtvremote2"];

  meta = with lib; {
    description = "A Python library for interacting with Android TV using the Android TV Remote protocol v2";
    homepage = "https://pypi.org/project/androidtvremote2/";
    license = licenses.asl20;
    maintainers = with maintainers; [];
  };
}
