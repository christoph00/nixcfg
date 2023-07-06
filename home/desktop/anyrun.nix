{
  pkgs,
  ...
}: {
  xdg.configFile."anyrun/config.ron".text = ''
    Config(
      // `width` and `vertical_offset` use an enum for the value it can be either:
      // Absolute(n): The absolute value in pixels
      // Fraction(n): A fraction of the width or height of the full screen (depends on exclusive zones and the settings related to them) window respectively

      // How wide the input box and results are.
      width: Absolute(800),

      // Where Anyrun is located on the screen: Top, Center
      position: Top,

      // How much the runner is shifted vertically
      vertical_offset: Fraction(0.3),

      // Hide match and plugin info icons
      hide_icons: false,

      // ignore exclusive zones, f.e. Waybar
      ignore_exclusive_zones: false,

      // Layer shell layer: Background, Bottom, Top, Overlay
      layer: Overlay,

      // Hide the plugin info panel
      hide_plugin_info: true,

      // Close window when a click outside the main box is received
      close_on_click: true,

      plugins: [
      "libapplications.so",
      "${pkgs.anyrun}/lib/libsymbols.so",
      "${pkgs.anyrun}/lib/libshell.so",
      "${pkgs.anyrun}/lib/libtranslate.so",
      "${pkgs.anyrun}/lib/librink.so",
      "${pkgs.anyrun}/lib/libkidex.so",
      "${pkgs.anyrun}/lib/libstdin.so",
      "${pkgs.anyrun}/lib/librandr.so",
      "libdictionary.so"
      ],
    )
  '';
}
