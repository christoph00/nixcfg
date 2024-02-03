{channels, ...}: final: prev: {
  obsidian = prev.obsidian.override {electron = final.electron_26;};
}
