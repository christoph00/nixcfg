{
  lib,
  python3,
  fetchPypi,
}:
python3.pkgs.buildPythonApplication rec {
  pname = "wyoming-piper";
  version = "0.0.2";
  format = "setuptools";

  src = fetchPypi {
    pname = "wyoming_piper";
    inherit version;
    hash = "sha256-uS6BHysRGnY4MO1HnU+GIyqTD2RNT/B4f1jXivI325E=";
  };

  propagatedBuildInputs = with pkgs; [
    wyoming
  ];

  pythonImportsCheck = ["wyoming_piper"];

  meta = with lib; {
    description = "Wyoming Server for Piper";
    homepage = "https://pypi.org/project/wyoming-piper/";
    license = licenses.mit;
    maintainers = with maintainers; [];
  };
}
