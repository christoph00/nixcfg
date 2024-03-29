{
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
    enable = mkBoolOpt false "Whether or not enable Ags.";
    package = mkOption {
      type = types.package;
      default = inputs.ags.packages.${pkgs.system}.agsWithTypes;
      defaultText = literalExpression "inputs.ags.packages.${pkgs.system}.default";
      description = lib.mdDoc ''
        ags package to use.
      '';
    };
  };

  config = mkIf cfg.enable {
    chr.home.extraOptions = {
      home.packages = [
        cfg.package
      ];

      # xdg.dataFile = {
      #   "ags/types" = {
      #     source = "${inputs.ags.packages.${pkgs.system}.agsWithTypes}/share/com.github.Aylur.ags/types";
      #     recursive = true;
      #   };
      # };

      # systemd.user.services.ags = {
      #   Unit.Description = "Aylurs GTK Shell";
      #   Unit.PartOf = ["hyprland-session.target"];
      #   Install.WantedBy = ["hyprland-session.target"];
      #   Service = {
      #     ExecStart = "${cfg.package}/bin/ags";
      #     Restart = "always";
      #     RestartSec = "3";
      #   };
      # };
    };
  };
}
