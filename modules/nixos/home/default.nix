{
  options,
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
with lib.chr;
let
  cfg = config.chr.home;
in
{
  options.chr.home = with types; {
    enable = mkOption {
      type = types.bool;
      default = builtins.elem config.chr.type [
        "desktop"
        "laptop"
      ];
    };
    file = mkOpt attrs { } (mdDoc "A set of files to be managed by home-manager's `home.file`.");
    configFile = mkOpt attrs { } (
      mdDoc "A set of files to be managed by home-manager's `xdg.configFile`."
    );
    extraOptions = mkOpt attrs { } "Options to pass directly to home-manager.";
  };

  config = mkIf cfg.enable {
    chr.home.extraOptions = {
      home.stateVersion = config.system.stateVersion;
      home.file = mkAliasDefinitions options.chr.home.file;
      xdg.enable = true;
      xdg.configFile = mkAliasDefinitions options.chr.home.configFile;

      systemd.user.startServices = "sd-switch";

      programs.home-manager.enable = true;

      chr.user.enable = config.chr.desktop.enable;
    };

    home-manager = {
      useUserPackages = true;
      useGlobalPkgs = true;

      users.${config.chr.user.name} = mkAliasDefinitions options.chr.home.extraOptions;
    };
  };
}
