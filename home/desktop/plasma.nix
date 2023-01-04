{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs;
    [
      kate
      konsole
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

  programs.plasma = {
    enable = true;
    workspace.clickItemTo = "select";
    files = {
      "plasma-localerc"."Formats" = {
        "LANG" = config.home.language.base;
        "LC_TIME" = config.home.language.time;
        "LC_PAPER" = config.home.language.paper;
        "LC_NUMERIC" = config.home.language.numeric;
        "LC_MONETARY" = config.home.language.monetary;
        "LC_MEASUREMENT" = config.home.language.measurement;
      };
    };
  };

  # home.persistence."/persist/home/christoph/Plasma" = {
  #   removePrefixDirectory = false;
  #   allowOther = true;
  #   directories = [
  #     #".config/gtk-3.0" # fuse mounted to /home/$USERNAME/.config/gtk-3.0
  #     #".config/gtk-4.0"
  #     ".config/KDE"
  #     ".config/kde.org"
  #     ".config/plasma-workspace"
  #     ".config/xsettingsd"
  #     ".kde"

  #     ".local/share/baloo"
  #     ".local/share/dolphin"
  #     ".local/share/kactivitymanagerd"
  #     ".local/share/kate"
  #     ".local/share/klipper"
  #     ".local/share/konsole"
  #     ".local/share/kscreen"
  #     ".local/share/kwalletd"
  #     ".local/share/kxmlgui5"
  #     ".local/share/RecentDocuments"
  #     ".local/share/sddm"
  #   ];
  #   files = [
  #     ".config/akregatorrc"
  #     ".config/baloofileinformationrc"
  #     ".config/baloofilerc"
  #     ".config/bluedevilglobalrc"
  #     ".config/device_automounter_kcmrc"
  #     ".config/dolphinrc"
  #     ".config/filetypesrc"
  #     #".config/gtkrc"
  #     #".config/gtkrc-2.0"
  #     ".config/gwenviewrc"
  #     ".config/kactivitymanagerd-pluginsrc"
  #     ".config/kactivitymanagerd-statsrc"
  #     ".config/kactivitymanagerd-switcher"
  #     ".config/kactivitymanagerdrc"
  #     ".config/katemetainfos"
  #     ".config/katerc"
  #     ".config/kateschemarc"
  #     ".config/katevirc"
  #     ".config/kcmfonts"
  #     ".config/kcminputrc"
  #     ".config/kconf_updaterc"
  #     ".config/kded5rc"
  #     ".config/kdeglobals"
  #     ".config/kgammarc"
  #     ".config/kglobalshortcutsrc"
  #     ".config/khotkeysrc"
  #     ".config/kmixrc"
  #     ".config/konsolerc"
  #     ".config/kscreenlockerrc"
  #     ".config/ksmserverrc"
  #     ".config/ksplashrc"
  #     ".config/ktimezonedrc"
  #     ".config/kwinrc"
  #     ".config/kwinrulesrc"
  #     ".config/kxkbrc"
  #     ".config/mimeapps.list"
  #     ".config/partitionmanagerrc"
  #     ".config/plasma-localerc"
  #     ".config/plasma-nm"
  #     ".config/plasma-org.kde.plasma.desktop-appletsrc"
  #     ".config/plasmanotifyrc"
  #     ".config/plasmarc"
  #     ".config/plasmashellrc"
  #     ".config/PlasmaUserFeedback"
  #     ".config/plasmawindowed-appletsrc"
  #     ".config/plasmawindowedrc"
  #     ".config/powermanagementprofilesrc"
  #     ".config/spectaclerc"
  #     ".config/startkderc"
  #     ".config/systemsettingsrc"
  #     ".config/Trolltech.conf"
  #     ".config/user-dirs.dirs"
  #     ".config/user-dirs.locale"

  #     ".local/share/krunnerstaterc"
  #     ".local/share/user-places.xbel"
  #     ".local/share/user-places.xbel.bak"
  #     ".local/share/user-places.xbel.tbcache"
  #   ];
  # };
}
