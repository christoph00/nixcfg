{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.wluma;

  format = pkgs.formats.toml {};

  #configFile = format.generate "config.toml" cfg.settings;
  configFile = pkgs.writeText "config.toml" cfg.config;
in {
  options.services.wluma = {
    enable = mkEnableOption "wluma";
    #settings = mkOption {
    #  type = format.type;
    #  default = {};
    #  description = "Configuration for wluma";
    #};
    config = mkOption {
      type = types.lines;
      default = ''{}'';
    };
  };

  config = mkIf cfg.enable {
    xdg.configFile."wluma/config.toml".source = configFile;
    systemd.user.services.wluma = {
      Unit = {Description = "Wluma auto brightness control";};

      Install = {WantedBy = ["graphical-session.target"];};

      Service = {
        ExecStart = "${pkgs.wluma}/bin/wluma";
      };
    };
  };
}
