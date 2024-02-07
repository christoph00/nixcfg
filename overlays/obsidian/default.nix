{channels, ...}: final: prev: {
  obsidian = prev.obsidian.override {
    electron = final.electron_25.overrideAttrs (_: {
      preFixup = "patchelf --add-needed ${final.libglvnd}/lib/libEGL.so.1 $out/bin/electron"; # NixOS/nixpkgs#272912
      meta.knownVulnerabilities = []; # NixOS/nixpkgs#273611
    });
  };
}
