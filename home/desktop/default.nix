{
  config,
  pkgs,
  lib,
}: {
  imports = [
    ./hyprland.nix
  ];

  scheme = "${inputs.base16-schemes}/tokyo-city-terminal-dark.yaml";

  home.pointerCursor = {
    name = "capitaine-cursors-white";
    package = pkgs.capitaine-cursors;
  };

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

      font = config.conf.fonts.serif.name;
      font-size = 15;

      line-uses-inside = true;
      disable-caps-lock-text = true;
      indicator-caps-lock = true;
      indicator-radius = 40;
      indicator-idle-visible = true;
      image = "${config.conf.theme.wallpaper}";

      ring-color = "${config.scheme.base02-hex}";
      inside-wrong-color = "${config.scheme.base08-hex}";
      ring-wrong-color = "${config.scheme.base08-hex}";
      key-hl-color = "${config.scheme.base0B-hex}";
      bs-hl-color = "${config.scheme.base08-hex}";
      ring-ver-color = "${config.scheme.base09-hex}";
      inside-ver-color = "${config.scheme.base09-hex}";
      inside-color = "${config.scheme.base01-hex}";
      text-color = "${config.scheme.base07-hex}";
      text-clear-color = "${config.scheme.base01-hex}";
      text-ver-color = "${config.scheme.base01-hex}";
      text-wrong-color = "${config.scheme.base01-hex}";
      text-caps-lock-color = "${config.scheme.base07-hex}";
      inside-clear-color = "${config.scheme.base0C-hex}";
      ring-clear-color = "${config.scheme.base0C-hex}";
      inside-caps-lock-color = "${config.scheme.base09-hex}";
      ring-caps-lock-color = "${config.scheme.base02-hex}";
      separator-color = "${config.scheme.base02-hex}";
    };
  };
}
