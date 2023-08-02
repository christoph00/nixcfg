{
  pkgs,
  config,
  ...
}: let
  sfwbarCss = with config.colorscheme.colors;
    pkgs.writeText "style.css" ''
      window#mainbar{
       font: 0.36cm ${config.fontProfiles.regular.family};
       background-color: #${base00};
       border-color: #${base02}
      }
      button#taskbar_normal image,
      button#taskbar_active image,
      button#taskbar_normal:hover image {
        min-width: 0.4cm;
        min-height: 0.4cm;
      }

      #hidden {
        -GtkWidget-visible: false;
      }

      button#taskbar_normal label,
      button#taskbar_active label,
      button#taskbar_normal:hover label {
        -GtkWidget-vexpand: true;
        padding-left: 0.75mm;
        padding-top: 0px;
        padding-bottom: 0px;
      }

      button#taskbar_normal,
      button#taskbar_active,
      button#taskbar_normal:hover {
        padding-left: 0.75mm;
        padding-top: 0.5mm;
        padding-bottom: 0.5mm;
        background-image: none;
        border-radius: 0;
        border-image: none;
      }

      button#taskbar_active {
        background-color: #${base04};
      }

      button#taskbar_normal:hover {
        background-color: #${base03};
      }

      button#pager_normal,
      button#pager_visible,
      button#pager_focused {
        padding-left: 1.25mm;
        padding-right: 1.25mm;
        padding-top: 0.5mm;
        padding-bottom: 0.5mm;
        background-image: none;
        border-radius: 0;
        border-image: none;
      }

      button#pager_focused {
        background-color: #${base04};
      }

      button#pager_preview {
        background-image: none;
        border-radius: 0;
        border-image: none;
        border-color: #${base00};
        border-width: 0.25mm;
        color: #777777;
        min-width: 5cm;
        min-height: 2.8125cm;
      }

      grid#pager {
        outline-color: #${base00};
        outline-style: dashed;
        outline-width: 0.25mm;
      }

      grid#switcher_active *,
      grid#switcher_active,
      grid#switcher_active * * {
        min-width: 1.25cm;
        min-height: 1.25cm;
        background-color: #${base02};
        border-image: none;
        border-radius: 1.25mm;
        padding: 1.25mm;
      }

      grid#switcher_normal *,
      grid#switcher_normal {
        min-width: 1.25cm;
        min-height: 1.25cm;
        border-image: none;
        padding: 1.25mm;
      }

      window#switcher {
        border-style: solid;
        border-width: 0.25mm;
        border-color: #${base04};
        border-radius: 1.25mm;
        padding: 1.25mm;
      }

      grid#switcher {
        border-radius: 1.25mm;
        padding: 1.25mm;
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
        min-width: 7mm;
        min-height: 7mm;
        padding: 1mm;
      }


      trough {
        border-style: inset;
        min-height: 2.5mm;
        min-width: 2.5mm;
      }

      label#time, label#date {
        min-width: 1.6cm;
      }

      grid#frame {
        -GtkWidget-direction: right;
        min-width: 2cm;
        border-color: #${base04};
        border-width: 0.5mm;
        padding-top: 0.25mm;
      }

      grid#layout {
        padding: 0.25mm;
        -GtkWidget-direction: right;
      }

      image#label {
        padding: 0.1cm;
      }

      label#value {
        min-width: 1cm;
        -GtkWidget-align: 0;
      }

      image#value_icon {
        min-width: 0.5cm;
        min-height: 0.5cm;
        padding: 0.1cm;
        padding-top: 1.5mm;
        padding-bottom: 1.5mm;
      }

      image#mpd {
        min-width: 0.4cm;
        min-height: 0.4cm;
        padding-top: 2mm;
        padding-bottom: 2mm;
        padding-left: 1mm;
        padding-right: 1mm;
      }

      label {
        color: #${base05};
      }

      tooltip label {
        color: #${base05};
      }
    '';
  sfwbarConfig = pkgs.writeText "sfwbar.config" ''
       function("SfwbarInit") {
         SetLayer "overlay"
        # SetMonitor "eDP-1"
       }

       function("ToggleMinimize") {
         [!Minimized] Minimize
         [Minimized] UnMinimize
       }

       function("ToggleMaximize") {
         [!Maximized] Maximize
         [Maximized] UnMaximize
       }

       menu("winops") {
         item("focus", Focus );
         item("close", Close );
         item("(un)minimize", Function "ToggleMinimize" );
         item("(un)maximize", Function "ToggleMaximize" );
       }

       placer {
         xstep = 5    # step by 5% of desktop horizontally
         ystep = 5    # step by 5% of desktop vertically
         xorigin = 5
         yorigin = 5
         children = false
       }

       # Task Switcher

       switcher {
         interval = 700
         icons = true
         labels = false
         cols = 5
       }

       menu ("menu") {
         	item("Browser",  Exec "${pkgs.firefox}/bin/firefox")
           item("Terminal", Exec "${pkgs.foot}/bin/footclient")
       }

       # Panel layout

       layout {

        # menu
       	button {
       		value = "gnome_badge-symbolic"
       		css = "* { padding: 0px 8px 0px 8px; background: none }"
       		action = Menu "menu"
       	}
         pager {
           preview = true
           rows = 1
           pins = "1","2","3","4"
         }

         # add a taskbar
         taskbar {
           icons = true     # display icons
           labels = true # display titles
           rows = 1        # stack window buttons across two rows
           action[3] = Menu "winops"
         }

         tray

    	  label {
    		  style = "time"
    		  interval = 1000
    		  value = Time("%H:%M")
        }

    }
  '';
in {
  systemd.user.services.sfwbar = {
    Unit = {
      Description = "sfwbar";
      After = ["graphical-session.target"];
      PartOf = ["graphical-session.target"];
    };

    Service = {
      Type = "simple";
      Restart = "on-failure";
      ExecStart = "${pkgs.sfwbar}/bin/sfwbar -f ${sfwbarConfig} -c ${sfwbarCss}";
    };

    Install = {WantedBy = ["graphical-session.target"];};
  };
}
