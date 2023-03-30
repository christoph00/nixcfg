{pkgs, ...}: let
  eww-yuck = pkgs.writeText "eww.yuck" ''
    ;; VARS /////////////////
    (defpoll clock-time :interval "10s" "date +'%H:%M'")
    (deflisten spaces :initial "{\"active\":0, \"workspaces\":[]}"
    `${pkgs.eww-ws}/bin/eww-ws`)
    (defvar volume 100)


    ;; /////////////////////
    (defwidget metric [label value onchange]
    (box :orientation "h"
       :class "metric"
       :space-evenly false
    (box :class "label" label)
    (scale :min 0
           :max 101
           :active {onchange != ""}
           :value value
           :onchange onchange)))

    ;; ///////////////////////

    (defwidget workspaces []
    (box :class "workspaces"
       :orientation "h"
       :space-evenly true
       :halign "start"
       :spacing 10
      (for entry in "''${spaces.workspaces}"
        (button :onclick "hyprctl dispatch workspace ''${entry.id}" "''${entry.name}"))
      ))

    (defwidget time []
    (box :class "time"
       :orientation "h"
       :space-evenly false
       :halign "center"
    clock-time))

    (defwidget sysinfo []
    (box :class "sidestuff" :orientation "h" :space-evenly false :halign "end"
    (metric :label "󰕾"
            :value volume
            :onchange "")
    (metric :label ""
            :value {EWW_RAM.used_mem_perc}
            :onchange "")
    (metric :label "󰆓"
            :value {round((1 - (EWW_DISK["/"].free / EWW_DISK["/"].total)) * 100, 0)}
            :onchange "")
    ))

    (defwidget bar []
    (centerbox :orientation "h"
      (workspaces)
      (time)
      (sysinfo)
    ))

    ;;     󰓓    󰝰       

    (defwindow bar
      :monitor 0
      :geometry (geometry :x "0%"
    		:y "0%"
    		:height "4%"
    		:width "100%"
    		:anchor "center bottom")
     :stacking "fg"
     :exclusive true
      (bar)
    )
  '';

  eww-scss = pkgs.writeText "eww.scss" ''

        .sidestuff slider {
          all: unset;
          color: #ffd5cd;
        }

        .workspaces button:hover {
          color: #D35D6E;
        }

        .metric scale trough highlight {
      all: unset;
      background-color: #D35D6E;
      color: #000000;
      border-radius: 10px;
    }
    .metric scale trough {
      all: unset;
      background-color: #4e4e4e;
      border-radius: 50px;
      min-height: 3px;
      min-width: 50px;
      margin-left: 10px;
      margin-right: 20px;
    }
    .metric scale trough highlight {
      all: unset;
      background-color: #D35D6E;
      color: #000000;
      border-radius: 10px;
    }
    .metric scale trough {
      all: unset;
      background-color: #4e4e4e;
      border-radius: 50px;
      min-height: 3px;
      min-width: 50px;
      margin-left: 10px;
      margin-right: 20px;
    }


  '';

  eww-config = pkgs.linkFarm "eww-config" [
    {
      name = "eww.yuck";
      path = eww-yuck;
    }
    {
      name = "eww.scss";
      path = eww-scss;
    }
  ];
in {
  programs.eww.enable = true;
  programs.eww.configDir = eww-config;
  programs.eww.package = pkgs.eww-wayland;
}
