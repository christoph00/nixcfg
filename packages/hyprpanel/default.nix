{
  lib,
  buildGoModule,
  fetchFromGitHub,
  pkg-config,
  glib,
  gobject-introspection,
  gtk4,
  gtk4-layer-shell,
  gdk-pixbuf,
  graphene,
  cairo,
  pango,
  wrapGAppsHook,
}:

buildGoModule rec {
  pname = "hyprpanel";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "pdf";
    repo = "hyprpanel";
    rev = "v${version}";
    hash = "sha256-4KDj3GLlXI/wxUt1gbWi2I/h1sP+nAcsLF1Lh51emnM=";
  };

  vendorHash = "sha256-q9HwcbtWk9LJOFmm7yyVWGjnvjWRnwDA+wqYGzysdiE=";

  nativeBuildInputs = [
    gobject-introspection
    pkg-config
    wrapGAppsHook
  ];

  buildInputs = [
    glib
    gtk4
    gtk4-layer-shell
    gdk-pixbuf
    graphene
    cairo
    pango
  ];

  meta = {
    description = "An opinionated panel/shell for the Hyprland compositor";
    homepage = "https://github.com/pdf/hyprpanel";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "hyprpanel";
  };
}
