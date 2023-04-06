{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (config.lib.formats.rasi) mkLiteral;
in {
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    font = "${config.fontProfiles.monospace.family} 12";
    plugins = [pkgs.rofi-calc pkgs.rofi-emoji];
    terminal = "${pkgs.foot}/bin/foot";
    location = "center";
    extraConfig = {
      display-drun = "";
      drun-display-format = "{name}";
      show-icons = true;
      hover-select = true;
    };
    theme = with config.colorscheme.colors; {
      "*" = {
        text-color = mkLiteral "#${base05}";
        background-color = mkLiteral "#${base00}";

        margin = 0;
        padding = 0;
        spacing = 0;
      };

      "window" = {
        background-color = mkLiteral "#${base00}";
        border-radius = mkLiteral "16px";
      };

      "mainbox" = {
        padding = mkLiteral "12px";
      };

      "inputbar" = {
        background-color = mkLiteral "#${base01}";

        border-color = mkLiteral "#${base03}";
        border = mkLiteral "2px";
        border-radius = mkLiteral "6px";

        padding = mkLiteral "8px 16px";
        spacing = mkLiteral "8px";
        children = map mkLiteral ["prompt" "entry"];
      };

      "prompt" = {
        text-color = mkLiteral "#${base06}";
      };

      "entry" = {
        placeholder = "Search";
        placeholder-color = mkLiteral "#${base03}";
        background-color = mkLiteral "inherit";
      };

      "message" = {
        margin = mkLiteral "12px 0 0";
        border-radius = mkLiteral "16px";
        border-color = mkLiteral "#${base03}";
        background-color = mkLiteral "#${base02}";
      };

      "textbox" = {
        padding = mkLiteral "8px 24px";
      };

      "listview" = {
        background-color = mkLiteral "transparent";

        margin = mkLiteral "12px 0 0";
        lines = mkLiteral "8";
        columns = mkLiteral "1";

        fixed-height = mkLiteral "false";
      };

      "element" = {
        padding = mkLiteral "8px 16px";
        spacing = mkLiteral "8px";
        border-radius = mkLiteral "8px";
        background = mkLiteral "inherit";
        text-color = mkLiteral "inherit";
      };

      "element normal active" = {
        text-color = mkLiteral "#${base09}";
      };

      "element selected normal, element selected active" = {
        background-color = mkLiteral "#${base01}";
      };

      "element-icon" = {
        size = mkLiteral "1em";
        vertical-align = mkLiteral "0.5";
      };

      "element-text" = {
        text-color = mkLiteral "inherit";
        background-color = mkLiteral "inherit";
      };
    };
  };
}
