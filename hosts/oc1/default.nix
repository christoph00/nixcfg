{
  config,
  lib,
  pkgs,
  ...
}: {
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = ["defaults" "size=2G" "mode=755"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/0C57-60FD";
    fsType = "vfat";
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/8521cf96-09fd-43f8-a1e7-82b853ac0320";
    fsType = "ext4";
  };

  swapDevices = [];

  networking.hostName = "oc1";

  powerManagement.cpuFreqGovernor = "performance";

  # ----------  Secrets  -----------------------------------------
  #age.secrets.cloudflared.file = ../../secrets/oca-cf;
  #age.secrets.tailscale-preauthkey.file = ../../secrets/tailscale-preauthkey;
  #age.secrets.cf-acme.file = ../../secrets/cf-acme;
}
