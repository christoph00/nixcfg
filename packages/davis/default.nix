{
  lib,
  php82,
  fetchFromGitHub,
}: let
  phpPackage = php82.withExtensions ({
    enabled,
    all,
  }:
    enabled ++ [all.imap all.gd all.intl all.pdo_sqlite]);
in
  phpPackage.buildComposerProject rec {
    pname = "davis";
    version = "4.4.1";

    src = fetchFromGitHub {
      owner = "tchapi";
      repo = "davis";
      rev = "v${version}";
      hash = "sha256-UBekmxKs4dveHh866Ix8UzY2NL6ygb8CKor+V3Cblns=";
    };

    php = phpPackage;

    passthru = {
      phpPackage = phpPackage;
    };

    meta = with lib; {
      description = "A simple, fully translatable admin interface for sabre/dav based on Symfony 5 and Bootstrap 5, initially inspired by Baïkal";
      homepage = "https://github.com/tchapi/davis";
      license = licenses.mit;
      maintainers = with maintainers; [];
      mainProgram = "davis";
      platforms = platforms.all;
    };
  }
