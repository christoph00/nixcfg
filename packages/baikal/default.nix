{
  lib,
  php82,
  fetchFromGitHub,
}:
let
  phpPackage = php82.withExtensions (
    { enabled, all }:
    enabled
    ++ [
      all.imap
      all.gd
      all.intl
      all.pdo_sqlite
    ]
  );
in
phpPackage.buildComposerProject rec {
  pname = "baikal";
  version = "0.9.4";

  src = fetchFromGitHub {
    owner = "sabre-io";
    repo = "Baikal";
    rev = version;
    hash = "sha256-McxKGxNF8dELmFXI7q1i/VWZZVGuVieIT1WrcynuH4Q=";
  };

  php = phpPackage;

  vendorHash = "sha256-cNRdu6RWd4ckxJq9RHTTxVRQ52FN3nBBo7kz0jd6WY0=";

  composerNoPlugins = false;
  composerStrictValidation = false;
  composerLock = ./composer.lock;

  passthru = {
    phpPackage = phpPackage;
  };

  meta = with lib; {
    description = "Baïkal is a Calendar+Contacts server";
    homepage = "https://github.com/sabre-io/Baikal";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
  };
}
