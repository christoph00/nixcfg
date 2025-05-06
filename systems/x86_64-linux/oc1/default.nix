{ ... }:
{
  facter.reportPath = ./facter.json;

  networking.hostName = "oc1";

  internal.type = "bootstrap";
  internal.system.fs.device = "/dev/sda";
  internal.system.boot.encryptedRoot = false;
  internal.system.fs.swapSize = "1G";
  internal.system.fs.tmpRoot = false;

  system.stateVersion = "24.11";
}
