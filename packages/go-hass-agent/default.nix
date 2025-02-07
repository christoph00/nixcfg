{ stdenv, lib, pkgs, buildGo123Module,
# workaround till buildGoModule uses go 1.23 by default
pkg-config, glfw, xorg, mage, writeShellScriptBin, git, ... }:

buildGo123Module rec {
  pname = "go-hass-agent";
  version = "11.1.0";

  src = pkgs.fetchFromGitHub {
    owner = "joshuar";
    repo = "go-hass-agent";
    rev = "v${version}";
    hash = "sha256-YlRoVUixGlDD96/7pCQMy9opP9/pIGrr3w2CLIASRX8=";
  };

  vendorHash = "sha256-ZPNXU0lBNN6yBuLvYK8rICtWN6jgv6oeArRyIcnPi9w=";

  doCheck = false;

  nativeBuildInputs = let
    fakeGit = writeShellScriptBin "git" ''
      if [[ $@ = "describe --tags --always --dirty" ]]; then
          echo "${version}"
      elif [[ $@ = "rev-parse --short HEAD" ]]; then
          echo "dummyrev"
      elif [[ $@ = "log --date=iso8601-strict -1 --pretty=%ct" ]]; then
          echo "0"
      else
          ${git}/bin/git $@
      fi
    '';
  in [ fakeGit pkg-config mage ];
  buildInputs = with xorg; [
    glfw
    libX11
    libXcursor
    libXrandr
    libXinerama
    libXi
    libXxf86vm
  ];

  buildPhase = ''
    runHook preBuild

    # Fixes “Error: error compiling magefiles” during build.
    export HOME=$(mktemp -d)

    mage -d build/magefiles -w . build:full

    runHook postBuild
  '';

  installPhase = ''
      runHook preInstall
      mv dist/go-hass-agent-* dist/go-hass-agent
    install -Dt $out/bin dist/go-hass-agent
    runHook postInstall
  '';
  meta = {
    description = "A Home Assistant, native app for desktop/laptop devices";
    homepage = "https://github.com/joshuar/go-hass-agent";
    changelog =
      "https://github.com/joshuar/go-hass-agent/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    mainProgram = "go-hass-agent";
  };
}
