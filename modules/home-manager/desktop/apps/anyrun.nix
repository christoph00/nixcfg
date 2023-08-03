{
  pkgs,
  inputs,
  config,
  ...
}: {
  programs.anyrun = {
    enable = true;

    config = {
      plugins = with inputs.anyrun.packages.${pkgs.system}; [
        applications
        #randr
        rink
        shell
        symbols
      ];

      # the x coordinate of the runner
      #x.relative = 800;
      # the y coordinate of the runner
      #y.absolute = 500.0;
      y.fraction = 0.0;

      # Hide match and plugin info icons
      hideIcons = false;

      # ignore exclusive zones, i.e. Waybar
      ignoreExclusiveZones = false;

      # Layer shell layer: Background, Bottom, Top, Overlay
      layer = "overlay";

      # Hide the plugin info panel
      hidePluginInfo = false;

      # Close window when a click outside the main box is received
      closeOnClick = true;

      # Show search results immediately when Anyrun starts
      showResultsImmediately = false;

      # Limit amount of entries shown in total
      maxEntries = null;
    };

    extraCss = with config.colorscheme.colors; ''
      * {
        transition: 100ms ease;
        font-family: "Noto Sans";
        font-size: 1rem;
      }

      #window,
      #match,
      #entry,
      #plugin,
      #main {
        background: transparent;
      }

      #match:selected {
        background: alpha(#${base03},0.8);
      }

      #match {
        padding: 3px;
        border-radius: 8px;
      }

      #entry, #plugin:hover {
        border-radius: 8px;
      }

      box#main {
        background: alpha(#${base00},0.8);
        border: 1px solid alpha(#${base03},0.8);
        border-radius: 16px;
        padding: 8px;
      }
    '';
  };
}
