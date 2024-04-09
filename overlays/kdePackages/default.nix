final: prev: {
  kdePackages =
    prev.kdePackages
    // {
      sddm = prev.kdePackages.sddm.overrideAttrs (old: {
        patches =
          (old.patches or [])
          ++ [
            (final.fetchpatch {
              url = "https://patch-diff.githubusercontent.com/raw/sddm/sddm/pull/1779.patch";
              sha256 = "sha256-8QP9Y8V9s8xrc+MIUlB7iHVNHbntGkw0O/N510gQ+bE=";
            })
          ];
      });
    };
}
