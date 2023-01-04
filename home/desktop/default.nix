{
  pkgs,
  lib,
  config,
  system,
  inputs,
  ...
}: {
  imports = [
    ./hyprland.nix
    ./waybar.nix
    ./gtk.nix
  ];

  #scheme = "${inputs.base16-schemes}/tokyo-city-terminal-dark.yaml";

  colorScheme = inputs.nix-colors.colorSchemes.dracula;

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "true";
    QT_QPA_PLATFORM = "wayland";
    LIBSEAT_BACKEND = "logind";
  };

  dconf.enable = true;

  services.wlsunset = {
    enable = true;
    longitude = "52.37052";
    latitude = "9.73322";
    temperature.day = 6500;
    temperature.night = 3500;
  };

  programs.mako = {
    enable = true;
    borderSize = 3;
    padding = "20";
    margin = "30";
    width = 500;
    height = 600;
    defaultTimeout = 10000;
  };

  programs.swaylock = {
    settings = {
      effect-blur = "20x3";
      fade-in = 0.1;
      #font = config.conf.fonts.serif.name;
      font-size = 15;

      line-uses-inside = true;
      disable-caps-lock-text = true;
      indicator-caps-lock = true;
      indicator-radius = 40;
      indicator-idle-visible = true;
      #image = "${config.conf.theme.wallpaper}";
    };
  };
}
