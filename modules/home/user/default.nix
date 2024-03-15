{
  lib,
  config,
  pkgs,
  osConfig ? {},
  inputs,
  ...
}: let
  inherit (lib) types mkIf mkDefault mkMerge;
  inherit (lib.chr) mkOpt;

  cfg = config.chr.user;

  home-directory =
    if cfg.name == null
    then null
    else "/home/${cfg.name}";
in {
  options.chr.user = {
    enable = mkOpt types.bool false "Whether to configure the user account.";
    name = mkOpt (types.nullOr types.str) "christoph" "The user account.";

    fullName = mkOpt types.str "Christoph" "The full name of the user.";
    email = mkOpt types.str "christoph@asche.co" "The email of the user.";

    home = mkOpt (types.nullOr types.str) home-directory "The user's home directory.";
  };

  imports = [
    inputs.anyrun.homeManagerModules.default
    inputs.nixvim.homeManagerModules.nixvim
    inputs.hyprland.homeManagerModules.default
    inputs.hyprlock.homeManagerModules.default
    inputs.hypridle.homeManagerModules.default
    inputs.ironbar.homeManagerModules.default
  ];

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion = cfg.name != null;
          message = "chr.user.name must be set";
        }
        {
          assertion = cfg.home != null;
          message = "chr.user.home must be set";
        }
      ];

      home = {
        username = mkDefault cfg.name;
        homeDirectory = mkDefault cfg.home;
      };

      xdg.configFile."fontconfig/conf.d/10-hm-fonts.conf".force = true;
      # home.file.".gtkrc-2.0".force = true;
    }
  ]);
}
