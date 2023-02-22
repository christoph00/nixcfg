{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs;
    [
      kate
      konsole
      libsForQt5.bismuth
    ]
    ++ (with plasma5Packages; [
      kmail
      kmail-account-wizard
      kmailtransport
      kalendar
      kaddressbook
      accounts-qt
      kdepim-runtime
      kdepim-addons
      ark
      okular
      filelight
      partition-manager
      plasma-browser-integration
    ]);
}
