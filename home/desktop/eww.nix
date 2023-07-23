{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: let
  dependencies = with pkgs; [
    brightnessctl
    pamixer
    coreutils
    hyprland
  ];

  eww-yuck = pkgs.writeText "eww.yuck" ''
    ;; VARS /////////////////
    (defpoll HYPRWINDOW :interval "1s" `${pkgs.hyprland}/bin/hyprctl activewindow -j`)
    (defpoll CLOCK :interval "5s" `date "+%H:%M"`)
    (defvar  VOLUME 80)
    (defvar  BRIGHTNESS 25)



    ;; WIDGETS

    (defwidget app [name icon command]
    (button :onclick "''${command} &"
      (image  :image-width 15
              :image-height 15
              :path "${pkgs.papirus-icon-theme}/share/icons/Papirus/48x48/apps/''${icon}.svg")
    ))

    (defwidget left []
      (box :orientation "h" :spacing 10 :valign "center" :halign "start" :space-evenly "false" :vexpand "false" :hexpand "false"
        (label :class "workspace" :halign "start" :text "''${HYPRWINDOW.workspace.name}")
    ))
    (defwidget center []
      (box :orientation "h" :spacing 10 :valign "center" :halign "center" :space-evenly "false" :vexpand "false" :hexpand "false"
        (label :class "clock" :halign "start" :text CLOCK)
    ))
    (defwidget right []
      (box :orientation "h" :spacing 10 :valign "center" :halign "end" :space-evenly "false" :vexpand "false" :hexpand "false"
        (label :class "volume" :halign "start" :text VOLUME)
        (label :class "battery" :halign "start" :text "''${EWW_BATTERY["BAT0"].capacity}%")
    ))


    (defwidget bar []
    (centerbox :orientation "h"
      (left)
      (center)
      (right)))

    ;; WINDOWS

    (defwindow bar
      :monitor 0
      :geometry (geometry :x "0"
                          :y "0"
                          :width "100%"
                          :height "30px"
                          :anchor "bottom center")
      :exclusive true
      :stacking "bg"
      (bar))


      ;; (label :class "workspace" :halign "start" :text "''${WORKSPACES.active}")
      ;; (for entry in "''${spaces.workspaces}"
      ;; (button :onclick "hyprctl dispatch workspace ''${entry.id}" "''${entry.name}"))
      ;;     󰓓    󰝰       


  '';

  eww-scss = pkgs.writeText "eww.scss" ''


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
  programs.eww.package = inputs.eww.packages.x86_64-linux.default.override {withWayland = true;};

  systemd.user.services.eww = {
    Unit = {
      Description = "Eww daemon";
      PartOf = ["graphical-session.target"];
    };
    Service = {
      Environment = "PATH=/run/wrappers/bin:${lib.makeBinPath dependencies}";
      ExecStart = "${config.programs.eww.package}/bin/eww daemon --no-daemonize";
      Restart = "on-failure";
    };
    Install.WantedBy = ["graphical-session.target"];
  };
}
