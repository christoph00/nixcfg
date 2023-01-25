{
  pkgs,
  config,
  ...
}: {
  systemd.user.services.sfwbar = {
    Unit = {
      Description = "sfwbar";
      After = ["graphical-session.target"];
      PartOf = ["graphical-session.target"];
    };

    Service = {
      Type = "simple";
      Restart = "on-failure";
      ExecStart = "${pkgs.sfwbar}/bin/sfwbar";
    };

    Install = {WantedBy = ["graphical-session.target"];};
  };

  xdg.configFile."sfwbar/sfwbar.config".text = ''
      # Window Placer
    placer {
      xorigin = 5  # place the first window at X% from the left
      yorigin = 5  # place the first window at X% from the top
      xstep = 5    # step by X% of desktop horizontally
      ystep = 5    # step by X% of desktop vertically
      children = true
    }

    # Task Switcher
    switcher {
      interval = 700
      icons = true
      labels = false
      cols = 5
    }

    function("SfwbarInit") {
      SetBarId "bar-0"
      SetLayer "top"
      SetExclusiveZone "-1"
      SetMonitor "eDP-1"
    #  SetBarSize "bar1","800"
    }

    function("ToggleMinimize") {
      [!Minimized] Minimize
      [Minimized] UnMinimize
    }

    function("ToggleMaximize") {
      [!Maximized] Maximize
      [Maximized] UnMaximize
    }

    function("ToggleValue") {
      [!UserState] UserState "on"
      [!UserState] SetValue "firefox"
      [UserState] UserState "off"
      [UserState] SetValue "alacritty"
    }

    menu("winops") {
      item("focus", Focus );
      item("close", Close );
      item("(un)minimize", Function "ToggleMinimize" );
      item("(un)maximize", Function "ToggleMaximize" );
    }

    # Panel layout

    layout "tint2" {
        image {
          value = "firefox"
          action = "firefox"                        # launch firefox on click
          style = "launcher"
        }
        image {
          value = "Alacritty"
          action = "alacritty"
          style = "launcher"
        }

      pager {
        style = "pager"
        rows = 1
        preview = true
        numeric = true
      }

      taskbar {
        rows = 1
        css = "* { -GtkWidget-hexpand: true; }" # stretch horizontally
        icons = true
        labels = true
        action[3] = Menu "winops"
      }


      tray {
        rows = 1
      }

      grid {
        css = "* { padding-left: 5px; padding-right: 5px; }"
        label {
          value = Time("%k:%M")
          loc(1,1)
        }
        label {
          value = Time("%A %e %B")
          loc(1,2)
        }
      }
    }

    #CSS
    window#tint2 {
      -GtkWidget-direction: bottom;
      background-color: rgba(0,0,0,0.6);
      border-color: rgba(0,0,0,0.3);
    }

    #hidden {
      -GtkWidget-visible: false;
    }

    button#taskbar_normal grid {
      -GtkWidget-hexpand: false;
      padding-right: 0px;
      margin-right: 0px;
    }

    button#taskbar_normal image, button#taskbar_active image, button#taskbar_normal:hover image {
      -GtkWidget-vexpand: true;
      box-shadow: none;
      border: none;
      border-image: none;
      background-image: none;
      background: none;
      min-width: 24px;
      min-height: 24px;
      -gtk-icon-shadow: none;
    }

    button#taskbar_normal label, button#taskbar_active label, button#taskbar_normal:hover label {
      -GtkWidget-vexpand: true;
      -GtkWidget-hexpand: false;
      padding-left: 0.75mm;
      padding-top: 0px;
      padding-bottom: 0px;
      font: 0.3cm Sans;
    }

    button#taskbar_normal , button#taskbar_active , button#taskbar_normal:hover {
      padding-left: 0.75mm;
      padding-top: 0.5mm;
      padding-bottom: 0.5mm;
      background-image: none;
      border-radius: 4px;
      border-image: none;
      -GtkWidget-hexpand: false;
      -GtkWidget-vexpand: true;
      background-color: rgba(119,119,119,0.2);
      border-color: rgba(119,119,119,0.3);
      box-shadow: none;
    }

    button#taskbar_active {
      background-color: rgba(119,119,119,0.2);
      border-color: rgba(255,255,255,0.4);
    }

    button#taskbar_normal:hover , button#taskbar_active:hover {
      background-color: rgba(176,176,176,0.22);
      border-color: rgba(234,234,234,0.44);
    }

    button#pager_normal , button#pager_visible , button#pager_focused {
      padding-left: 1.25mm;
      padding-right: 1.25mm;
      padding-top: 0.5mm;
      padding-bottom: 0.5mm;
      background-image: none;
      border-radius: 4px;
      border-image: none;
      font: 0.3cm Sans;
      background-color: rgba(119,119,119,0.0);
      border-color: rgba(119,119,119,0.0);
      box-shadow: none;
    }

    button#pager_focused {
      background-color: rgba(119,119,119,0.2);
      border-color: rgba(255,255,255,0.0);
    }

    button#pager_preview {
      background-image: none;
      border-radius: 0;
      border-image: none;
      border-color: #000000;
      border-width: 0.25mm;
      color: #777777;
      min-width: 5cm;
      min-height: 2.8125cm;
    }

    grid#pager {
      outline-color: #000000;
      outline-style: dashed;
      outline-width: 0.25mm;
    }

    grid#switcher_active image,
    grid#switcher_active {
      min-width: 1.25cm;
      min-height: 1.25cm;
      border-image: none;
      padding: 1.25mm;
      background-color: #777777;
      border: 0px;
      box-shadow: none;
      border-radius: 1.25mm;
      -GtkWidget-hexpand: true;
    }

    grid#switcher_normal image,
    grid#switcher_normal {
      min-width: 1.25cm;
      min-height: 1.25cm;
      border-image: none;
      padding: 1.25mm;
      -GtkWidget-direction: right;
      -GtkWidget-hexpand: true;
    }

    window#switcher {
      border-style: solid;
      border-width: 0.25mm;
      border-color: #000000;
      border-radius: 1.25mm;
      padding: 1.25mm;
      -GtkWidget-hexpand: true;
    }

    grid#switcher {
      border-radius: 1.25mm;
      padding: 1.25mm;
      background-color: rgba(0,0,0,0.8);
      border-color: rgba(119,119,119,0.8);
      box-shadow: none;
      -GtkWidget-hexpand: true;
    }

    button#tray_active,
    button#tray_passive,
    button#tray_attention {
      background-image: none;
      border: 0px;
      padding: 0px;
      margin: 0px;
      border-image: none;
      border-radius: 0px;
      outline-style: none;
      box-shadow: none;
    }

    button#tray_active image,
    button#tray_passive image,
    button#tray_attention image {
      min-width: 20px;
      min-height: 20px;
      padding: 1mm;
    }

    grid#layout {
      padding: 0.25mm;
      -GtkWidget-direction: right;
      min-height: 30px;
    }

    image#launcher {
      -GtkWidget-hexpand: true;
      -GtkWidget-vexpand: true;
      min-width: 24px;
      min-height: 24px;
      padding-right: 2px;
    }

    menu {
      background-color: rgba(0,0,0,0.8);
      border-color: rgba(119,119,119,0.3);
      box-shadow: none;
    }

    menuitem {
    color: #ffffff;
    }

    label {
      font: 0.27cm Sans;
      color: #ffffff;
      text-shadow: none;
    }

    * {
      -GtkWidget-vexpand: true;
    }
  '';
}
