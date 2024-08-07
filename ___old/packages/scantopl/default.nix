{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "scantopl";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "Celedhrim";
    repo = "scantopl";
    rev = "v${version}";
    hash = "sha256-usLxq8XKk5ljtDpjUlfVQNT1QFtsc0i94rPq6+CPcBE=";
  };

  vendorHash = "sha256-75KBjfmPbFbmJq4+gRHt5Z5FRWTL9HunVmHwxXYTUYg=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = with lib; {
    description = "Automatically upload file to paperless when filename match a prefix";
    homepage = "https://github.com/Celedhrim/scantopl/";
    license = licenses.wtfpl;
    maintainers = with maintainers; [];
    mainProgram = "scantopl";
  };
}
