{
  lib,
  python3,
  fetchFromGitHub,
  gtk4-layer-shell,
  gtk-layer-shell,
  gobject-introspection,
  gtk4,
  pkg-config,
  wrapGAppsHook3,
  cairo,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "ignis";
  version = "0.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "linkfrg";
    repo = "ignis";
    rev = "v${version}";
    hash = "sha256-V70DT1Czyj/rbBAQIqfRVlQOyeuLjk1F6P8XOagDxNw=";
    fetchSubmodules = true;
  };

  build-system = [
    python3.pkgs.setuptools
    # python3.pkgs.wheel
  ];

  propagatedBuildInputs = [
    gtk4
    gtk4-layer-shell
    gtk-layer-shell
  ];

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook3
    gobject-introspection
    cairo
  ];

  dependencies = with python3.pkgs; [
    click
    loguru
    pycairo
    pygobject3
    requests
    setuptools
    mypy
  ];

  doCheck = false;

  postPatch = ''
    # Fixes "Multiple top-level packages discovered in a flat-layout"
    sed -i '$ a\[project]' pyproject.toml
    sed -i '$ a\name  = "ignis"' pyproject.toml
    sed -i '$ a\version = "${builtins.toString version}"' pyproject.toml
    sed -i '$ a\[tool.setuptools]' pyproject.toml
    sed -i '$ a\packages = ["ignis"]' pyproject.toml
  '';

  prePatch = ''export HOME=$NIX_BUILD_TOP'';

  meta = {
    description = "Full-featured Python framework for building desktop shells using GTK4";
    homepage = "https://github.com/linkfrg/ignis";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "ignis";
  };
}
