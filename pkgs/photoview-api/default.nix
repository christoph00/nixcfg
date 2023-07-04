{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "photoview-api";
  version = "2.3.13";

  src = fetchFromGitHub {
    owner = "photoview";
    repo = "photoview";
    rev = "v${version}";
    hash = "sha256-O6k5nbiWTsuOi8YLX0rsZJ9dOIo5d6pdwjhFZrdwI0E=";
  } + "/api";


  vendorHash = "sha256-0SWywy9YdPtgvxRhwKhKvspPmhbnibSuhvzhsjIQvZk=";
  
  meta = with lib; {
    description = "Photo gallery for self-hosted personal servers";
    homepage = "https://github.com/photoview/photoview";
    license = licenses.agpl3Only;
 
  };
}
