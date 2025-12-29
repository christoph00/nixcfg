{
  pkgs,
  flake,
  lib,
  config,
  options,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (flake.lib) enabled;
  cfg = config.desktop;
in
{
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      brightnessctl
      gammastep
      wlsunset

      _7zz
      # _7zz-rar

      desktop-file-utils

      wev
      walker

      font-manager
      file-roller
      unrar

      nautilus

      neovide

      phinger-cursors
      # chicago95
      adw-gtk3

      #nwg-look
      adwaita-icon-theme
      adwaita-qt

      moonlight-qt

      vscode

      gohufont
    ];

    # foot
    environment.etc."xdg/foot/foot.ini".text = pkgs.lib.generators.toINI { } {
      main = {
        font = "BlexMono Nerd Font:size=11";
        pad = "8x8";
      };
      colors = {
        # modus operandi
        background = "ffffff";
        foreground = "000000";
        regular0 = "000000";
        regular1 = "a60000";
        regular2 = "005e00";
        regular3 = "813e00";
        regular4 = "0031a9";
        regular5 = "721045";
        regular6 = "00538b";
        regular7 = "bfbfbf";
        bright0 = "595959";
        bright1 = "972500";
        bright2 = "315b00";
        bright3 = "70480f";
        bright4 = "2544bb";
        bright5 = "5317ac";
        bright6 = "005a5f";
        bright7 = "ffffff";

        jump-labels = "dce0e8 0000ff";
      };
    };
  };
}
