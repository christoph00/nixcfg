{inputs, ...}: {
  programs.ironbar = {
    enable = true;
    package = inputs.ironbar.packages.x86_64-linux.default;
    config = let
      launcher = {
        type = "launcher";
        favorites = ["chromium" "foot"];
        show_names = false;
        show_icons = true;
        icon_theme = "Breeze";
      };

      tray = {type = "tray";};
      clock = {type = "clock";};
    in {
      position = "bottom";
      anchor_to_edges = true;
      start = [launcher];
      end = [tray clock];
    };
  };
}
