{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.services.gns3;
in {
  options.chr.services.gns3 = with types; {
    enable = mkBoolOpt false "Enable gns3 Service.";
    gui = mkBoolOpt false "Enable gns3 GUI.";
  };
  config = mkIf cfg.enable {
    services.gns3-server = {
      enable = true;
      settings = {
        "Server" = {
          "host" = "0.0.0.0";
          "port" = 3080;
        };
      };
      dynamips = {
        enable = true;
      };
      vpcs = {
        enable = true;
      };
      ubridge = {
        enable = true;
      };
    };

    systemd.services.gns3-server.path = [pkgs.qemu];

    environment.systemPackages = with pkgs; [
      gns3-gui
    ];
  };
}
