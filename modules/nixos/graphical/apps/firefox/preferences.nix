{ inputs, ... }:
let
  betterfox = builtins.replaceStrings [ "user_pref" ] [ "pref" ] (
    builtins.readFile "${inputs.betterfox}/user.js"
  );
  fastfox = builtins.replaceStrings [ "user_pref" ] [ "pref" ] (
    builtins.readFile "${inputs.betterfox}/Fastfox.js"
  );
in
''
  ${betterfox}
  ${fastfox}
  pref("intl.accept_languages", "en-us,en,de-de,de");
  pref("sidebar.position_start", false);
  pref("browser.toolbars.bookmarks.visibility", "never");
  pref("browser.bookmarks.restore_default_bookmarks", false);
  pref("browser.bookmarks.file", "");
  pref("media.videocontrols.picture-in-picture.video-toggle.enabled", false);
  pref("general.autoScroll", true);
  pref("middlemouse.paste", false);
  pref("signon.rememberSignons", false);
  pref("extensions.formautofill.creditCards.enabled", false);
  pref("browser.tabs.loadBookmarksInBackground", true);

  pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
  pref("svg.context-properties.content.enable", true);
  pref("layout.css.color-mix.enabled", true);

  pref("apz.overscroll.enabled", true); // DEFAULT NON-LINUX
  pref("general.smoothScroll", true); // DEFAULT
  pref("mousewheel.min_line_scroll_amount", 10); // 10-40; adjust this number to your liking; default=5
  pref("general.smoothScroll.mouseWheel.durationMinMS", 80); // default=50
  pref("general.smoothScroll.currentVelocityWeighting", "0.15"); // default=.25
  pref("general.smoothScroll.stopDecelerationWeighting", "0.6"); // default=.4

''
