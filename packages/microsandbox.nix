{
  pkgs,
  pname,
  ...
}:

pkgs.rustPlatform.buildRustPackage rec {
  inherit pname;
  version = "0.2.6";

  src = pkgs.fetchFromGitHub {
    owner = "microsandbox";
    repo = "microsandbox";
    rev = "microsandbox-v${version}";
    hash = "sha256-RecgVc51/1TUo/HY8mPI+wS3ND8X1NFDwPnXjlTAUyk=";
  };

  cargoHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  nativeBuildInputs = [
    pkgs.pkg-config
  ];

  buildInputs = with pkgs; [
    openssl
    sqlite
  ];

  meta = {
    description = "Self-Hosted Plaform for Secure Execution of Untrusted User/AI Code";
    homepage = "https://github.com/microsandbox/microsandbox";
    changelog = "https://github.com/microsandbox/microsandbox/blob/${src.rev}/CHANGELOG.md";
    license = pkgs.lib.licenses.asl20;
    mainProgram = "microsandbox";
  };
}
