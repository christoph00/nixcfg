{
  pkgs,
  config,
  ...
}:
{
  imports = [
    ../common
  ];

  config = {
    home.stateVersion = "25.05";
    manual = {
      manpages.enable = false;
      html.enable = false;
      json.enable = false;
    };
    systemd.user.startServices = "sd-switch";

    home.shell = {
      enableFishIntegration = true;
      enableNushellIntegration = true;
    };
    programs.nix-your-shell.enable = true;

    gtk.enable = true;

    gtk.theme = {
      # name = "adw-gtk3";
      name = "Adwaita";
      package = pkgs.adw-gtk3;
    };

    gtk.gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";

    programs = {
      nushell = {
        enable = true;
        extraConfig = ''

          $env.config = {
           show_banner: false,
           completions: {
            case_sensitive: false # case-sensitive completions
            quick: true    # set to false to prevent auto-selecting completions
            partial: true    # set to false to prevent partial filling of the prompt
            algorithm: "fuzzy"    # prefix or fuzzy
            }
          }
        '';
      };
      carapace = {
        enable = true;
        enableNushellIntegration = true;
      };
    };

  };

}
