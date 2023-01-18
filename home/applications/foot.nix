{
  pkgs,
  config,
  ...
}:
with config.colorscheme.colors; let
  mono-font = config.fontProfiles.monospace.family;
in {
  programs.foot = {
    enable = true;
    server.enable = true;
    settings = {
      main = {
        term = "xterm-256color";
        font = "${mono-font}:style=Medium:size=11";
        font-bold = "${mono-font}:style=Bold:size=11";
        font-italic = "${mono-font}:style=Medium Italic:size=11";
        font-bold-italic = "${mono-font}:style=Bold Italic:size=11";
        #dpi-aware = "yes";
        locked-title = "no";
        pad = "25x25";
      };
      cursor = {
        style = "block";
        color = "${base00} ${base05}";
        blink = "no";
      };
      colors = {
        alpha = 1.0;
        background = "${base00}";
        foreground = "${base05}";

        regular0 = "${base00}"; # black/bg
        regular1 = "${base08}"; # red
        regular2 = "${base0B}"; # green
        regular3 = "${base0A}"; # yellow
        regular4 = "${base0D}"; # blue
        regular5 = "${base0E}"; # magenta
        regular6 = "${base0C}"; # cyan
        regular7 = "${base05}"; # white/fg

        bright0 = "${base03}"; # bright black
        bright1 = "${base09}"; # bright red
        bright2 = "${base01}"; # bright green/lbg
        bright3 = "${base02}"; # bright yellow
        bright4 = "${base04}"; # bright blue
        bright5 = "${base06}"; # bright magenta
        bright6 = "${base0F}"; # bright cyan
        bright7 = "${base07}"; # bright white

        selection-foreground = "${base00}";
        selection-background = "${base05}";
        urls = "${base0D}";
        scrollback-indicator = "${base00} ${base0D}";
      };
    };
  };
}
