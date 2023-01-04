# unused right now... morally speaking should be moved to hardware for desktop only
{
  config,
  pkgs,
  lib,
  ...
}: let
  iommuGroups =
    pkgs.writeScriptBin "iommuGroups"
    ''
      #!${pkgs.bash}/bin/bash
      set -e -o pipefail
      shopt -s nullglob
      for d in /sys/kernel/iommu_groups/*/devices/*; do
          n=''${d#*/iommu_groups/*}; n=''${n%%/*}
          printf 'IOMMU Group %s ' "$n"
          ${pkgs.pciutils}/bin/lspci -nns "''${d##*/}"
      done;
    '';
in {

  environment.systemPackages = [
    iommuGroups
  ];

  #boot.kernelParams = ["intel_iommu=on" "iommu=pt"];

  boot.kernelParams = ["video=efifb:off" "intel_iommu=on" "iommu=pt"];
  #   boot.kernelParams = ["video=efifb:off" "intel_iommu=on" "intel_iommu=pt" "hugepagesz=1G" "hugepages=16"];

  boot.extraModprobeConfig = "options vfio-pci ids=1002:67df,1002:aaf0";
  # boot.kernelPatches = [
  #   {
  #     name = "vendor-reset";
  #     patch = null;
  #     extraConfig = ''
  #       FTRACE y
  #       KPROBES y
  #       PCI_QUIRKS y
  #       KALLSYMS y
  #       KALLSYMS_ALL y
  #       FUNCTION_TRACER y
  #     '';
  #   }
  # ];
  boot.extraModulePackages = [config.boot.kernelPackages.vendor-reset];
  boot.initrd.availableKernelModules = ["vendor-reset" "vfio" "vfio_iommu_type1" "vfio_pci" "vfio_virqfd"];
  boot.initrd.kernelModules = ["vendor-reset" "vfio" "vfio_iommu_type1" "vfio_pci" "vfio_virqfd" "tun"];
  boot.blacklistedKernelModules = ["radeon"];
  services.xserver.videoDrivers = ["amdgpu"];
  hardware.opengl.driSupport = true;
  hardware.opengl.extraPackages = with pkgs; [
    amdvlk
  ];

  # Dont Start Display Manager
  systemd.defaultUnit = lib.mkForce "multi-user.target";

  #systemd.tmpfiles.rules = [
  #  "f /dev/shm/looking-glass 0660 christoph qemu-libvirtd -"
  #];
}
