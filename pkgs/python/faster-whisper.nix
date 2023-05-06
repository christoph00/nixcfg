{ lib
, buildPythonPackage
, fetchPypi
, av
, ctranslate2
, huggingface-hub
, onnxruntime
, tokenizers
, transformers
, black
, flake8
, isort
, pytest
}:

buildPythonPackage rec {
  pname = "faster-whisper";
  version = "0.5.1";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-UibfDKQJMW2ah768zgUKphvlgeIMEPGpzJ6CT9SsvWI=";
  };

  propagatedBuildInputs = [
    av
    ctranslate2
    huggingface-hub
    onnxruntime
    tokenizers
  ];

  passthru.optional-dependencies = {
    conversion = [
      transformers
    ];
    dev = [
      black
      flake8
      isort
      pytest
    ];
  };

  pythonImportsCheck = [ "faster_whisper" ];

  meta = with lib; {
    description = "Faster Whisper transcription with CTranslate2";
    homepage = "https://pypi.org/project/faster-whisper/";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
