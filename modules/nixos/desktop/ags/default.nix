{
  options,
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.desktop.ags;
in {
  options.chr.desktop.ags = with types; {
    enable = mkBoolOpt config.chr.desktop.hyprland.enable "Whether or not enable Ags.";
  };

  config = mkIf cfg.enable {
    chr.home.extraOptions = {
      home.packages = [
        inputs.ags.packages.${pkgs.system}.default
      ];

      systemd.user.services.ags = {
        Unit.Description = "Aylurs GTK Shell";
        Unit.PartOf = ["hyprland-session.target"];
        Install.WantedBy = ["hyprland-session.target"];
        Service = {
          ExecStart = "${inputs.ags.packages.${pkgs.system}.default}/bin/ags";
          Restart = "always";
          RestartSec = "3";
        };
      };
    };
  };
}
