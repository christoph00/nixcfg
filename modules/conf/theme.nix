{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
with config.scheme; let
  cfg = config.conf.theme;
  nix-wallpaper = import ./nix-wallpaper.nix {inherit pkgs;};
in {
  options.conf.theme.enable = lib.mkEnableOption "theming";
  options.conf.theme.wallpaper = lib.mkOption {
    #type = lib.types.str;
    default = nix-wallpaper {
      scheme = config.scheme;
      width = 2560;
      height = 1080;
      logoScale = 5.0;
    };
    description = "Wallpaper";
  };
  config = lib.mkIf cfg.enable {
    scheme = "${inputs.base16-schemes}/tokyo-city-terminal-dark.yaml";

    # console.colors = [
    #   base00-hex
    #   base08-hex
    #   base0B-hex
    #   base0A-hex
    #   base0D-hex
    #   base0E-hex
    #   base0C-hex
    #   base05-hex
    #   base03-hex
    #   base09-hex
    #   base01-hex
    #   base02-hex
    #   base04-hex
    #   base06-hex
    #   base0F-hex
    #   base07-hex
    # ];

    home-manager.users.${config.conf.users.user} = {
      home.pointerCursor = {
        name = "capitaine-cursors-white";
        package = pkgs.capitaine-cursors;
      };
    };
  };
}
