{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      hunspell
      hunspellDicts.de_DE-large
      libreoffice-fresh
    ];
  };
}
