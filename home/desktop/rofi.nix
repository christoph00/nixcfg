{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    font = "${config.fontProfiles.monospace.family} 12";
    plugins = [pkgs.rofi-calc pkgs.rofi-emoji];
    terminal = "${pkgs.foot}/bin/footclient";
    extraConfig = {
      display-drun = "";
      drun-display-format = "{name}";
      show-icons = true;
    };
    theme = with config.colorscheme.colors; let
      inherit (config.lib.formats.rasi) mkLiteral;
    in {
      "*" = {
        text-color = mkLiteral "#${base05}";
        background-color = mkLiteral "#${base00}";
      };

      "#window" = {
        transparency = "background";
      };

      "#mainbox" = {
        padding = mkLiteral "20px 0px 20px 0px";
        background-color = mkLiteral "#${base05}";
        border = mkLiteral "0px";
        border-color = mkLiteral "#${base03}";
        border-radius = mkLiteral "0px";
        children = map mkLiteral ["inputbar" "message" "listview"];
      };

      "#inputbar" = {margin = mkLiteral "0px 0px 20px 20px";};

      "#element" = {padding = mkLiteral "12px 12px 12px 12px";};

      "#element-icon" = {
        horizontal-align = mkLiteral "0.5";
        vertical-align = mkLiteral "0.5";
        padding = mkLiteral "0px 10px 0px 5px";
      };

      "#element selected" = {
        background-color = mkLiteral "#${base00}";
        text-color = mkLiteral "#${base08}";
      };

      "#inputbar" = {
        children = map mkLiteral ["textbox-prompt-colon" "entry"];
      };

      "#textbox-prompt-colon" = {
        expand = false;
        str = " ";
        text-color = mkLiteral "#${base08}";
        margin = mkLiteral "0px 0.3em 0em 0em";
      };
    };
  };
}
