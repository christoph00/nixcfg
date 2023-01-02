{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.conf.profile;
in {
  options.conf.profile = {
    laptop = mkEnableOption "Laptop Profile";
    server = mkEnableOption "Server Profile";
    workstation = mkEnableOption "Workstation Profile";
    desktop = mkEnableOption "Desktop Profile";
  };

  config = mkIf cfg.laptop {
    # boot = {
    #   kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    # };

    # Lid settings
    services.logind = {
      lidSwitch = "hybrid-sleep";
      lidSwitchExternalPower = "hybrid-sleep";
      extraConfig = ''
        IdleAction=hybrid-sleep
        IdleActionSec=30min
      '';
    };
    # Fingerprint
    #    environment.etc."pam.d/gtklock".text = ''
    #      auth            sufficient      pam_unix.so try_first_pass likeauth nullok
    #      auth            sufficient      pam_fprintd.so
    #    '';
    #    services.fprintd.enable = true;

    home-manager.users.${config.conf.users.user} = {
      home.packages = with pkgs; [fprintd];
    };
    environment.persistence."/persist" = {
      directories = [
        "/var/lib/fprint"
      ];
    };
    services.power-profiles-daemon.enable = true;
  };
}
