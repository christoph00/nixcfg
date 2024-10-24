{ inputs, ... }:
let
  betterfox = builtins.replaceStrings [ "user_pref" ] [ "pref" ] (
    builtins.readFile "${inputs.betterfox}/user.js"
  );
  escapedUiState =
    builtins.replaceStrings [ ''"'' ] [ ''\"'' ]
      ''{"placements":{"widget-overflow-fixed-list":[],"unified-extensions-area":["sponsorblocker_ajay_app-browser-action","_762f9885-5a13-4abd-9c77-433dcd38b8fd_-browser-action","_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action","_74145f27-f039-47ce-a470-a662b129930a_-browser-action","ublock0_raymondhill_net-browser-action"],"nav-bar":["back-button","forward-button","stop-reload-button","customizableui-special-spring1","urlbar-container","customizableui-special-spring2","save-to-pocket-button","downloads-button","fxa-toolbar-menu-button","unified-extensions-button","sidebar-button"],"toolbar-menubar":["menubar-items"],"TabsToolbar":["firefox-view-button","tabbrowser-tabs","new-tab-button","alltabs-button"],"PersonalToolbar":["personal-bookmarks"]},"seen":["developer-button","sponsorblocker_ajay_app-browser-action","_762f9885-5a13-4abd-9c77-433dcd38b8fd_-browser-action","_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action","_74145f27-f039-47ce-a470-a662b129930a_-browser-action","ublock0_raymondhill_net-browser-action"],"dirtyAreaCache":["nav-bar","unified-extensions-area","PersonalToolbar","TabsToolbar","toolbar-menubar"],"currentVersion":20,"newElementCount":5}'';
in
''
  ${betterfox}
  pref("intl.accept_languages", "en-us,en,de-de,de");
  pref("browser.uiCustomization.state", "${escapedUiState}");
  pref("sidebar.position_start", false);
  pref("browser.toolbars.bookmarks.visibility", "always");
  pref("browser.bookmarks.restore_default_bookmarks", false);
  pref("browser.bookmarks.file", "");
  pref("media.videocontrols.picture-in-picture.video-toggle.enabled", false);
  pref("general.autoScroll", true);
  pref("middlemouse.paste", false);
  pref("signon.rememberSignons", false);
  pref("extensions.formautofill.creditCards.enabled", false);
  pref("browser.tabs.loadBookmarksInBackground", true);
''
