{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      hunspell
      hunspellDicts.de_DE
      libreoffice-qt
    ];
  };
}
