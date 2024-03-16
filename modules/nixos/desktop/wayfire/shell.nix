{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  style = pkgs.writeText "style.css" ''
    *:selected {
        background: none;
        border: none;
    }

    button {
        color: white;
        background: rgba(100, 100, 100, 0.3);
        border-width: 0px;
    }

    button.flat {
        background: rgba(0, 0, 0, 0);
    }

    button:hover {
        background: rgba(200, 200, 200, 0.2);
    }

    calendar {
        border: none;
        background: none;
    }

    calendar:selected {
        color: #c50ed2;
    }

    popover,window,entry {
        background: rgba(24, 27, 40, 0.4);
        box-shadow: none;
    }

    separator {
        background: rgba(255, 255, 255, 0.3);
    }
  '';
in {
  chr.desktop.wayfire.shell.settings = lib.mkIf config.chr.desktop.wayfire.shell.enable {
    background = {
      image = "~/Bilder/Wallpaper";
    };
    dock = {
      css_path = "${style}";
      autohide = false;
      dock_height = 64;
      icon_mapping_code-url-handler = "${pkgs.vscode}/share/pixmaps/vscode.png";
    };
    panel = {
      css_path = "${style}";
      position = "bottom";
      widgets_center = "none";
      widgets_left = "menu spacing4 launchers window-list";
      widgets_right = "notifications volume battery tray clock";

      launcher_nau = "org.gnome.Nautilus.desktop";
      launcher_thorium = "thorium-browser.desktop";

      menu_fuzzy_search = true;
    };
  };
}
