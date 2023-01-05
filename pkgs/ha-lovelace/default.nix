{pkgs}: {
  battery-entity = pkgs.callPackage ./battery-entity.nix {};
  card-mod = pkgs.callPackage ./card-mod.nix {};
  fold-entity-row = pkgs.callPackage ./fold-entity-row.nix {};
  mini-graph-card = pkgs.callPackage ./mini-graph-card.nix {};
}
