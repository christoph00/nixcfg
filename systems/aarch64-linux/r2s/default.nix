{
  config,
  lib,
  pkgs,
  modulesPath,
  inputs,
  ...
}:
with lib;
with lib.chr; let
  inherit (inputs) nixos-hardware;
in {
  networking.hostName = "r2s";

  chr = {
    type = "server";
  };

  hardware.deviceTree.name = "rockchip/rk3328-nanopi-r2s.dtb";

  # NanoPi R2S's DTS has not been actively updated, so just use the prebuilt one to avoid rebuilding
  hardware.deviceTree.package = mkForce (
    pkgs.runCommand "dtbs-nanopi-r2s" {} ''
      install -TDm644 ${./rk3328-nanopi-r2s.dtb} $out/rockchip/rk3328-nanopi-r2s.dtb
    ''
  );

  hardware.firmware = [
    (
      pkgs.runCommand
      "linux-firmware-r8152"
      {}
      ''
        install -TDm644 ${./rtl8153a-4.fw} $out/lib/firmware/rtl_nic/rtl8153a-4.fw
        install -TDm644 ${./rtl8153b-2.fw} $out/lib/firmware/rtl_nic/rtl8153b-2.fw
      ''
    )
  ];

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-label/NIXOS_BOOT";
      fsType = "ext4";
    };
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "f2fs";
      options = ["compress_algorithm=zstd:6" "compress_chksum" "atgc" "gc_merge" "lazytime"];
    };
  };

  boot = {
    loader = {
      timeout = 1;
      systemd-boot.enable = mkForce false;
      grub.enable = mkForce false;
      generic-extlinux-compatible = {
        enable = mkForce true;
        configurationLimit = 3;
      };
    };
    kernelPackages = pkgs.linuxPackages;
    kernelParams = [
      "console=ttyS2,1500000"
      "earlycon=uart8250,mmio32,0xff130000"
      "mitigations=off"
    ];
    initrd = {
      includeDefaultModules = false;
      kernelModules = ["ledtrig-netdev"];
    };
    blacklistedKernelModules = ["hantro_vpu" "drm" "lima" "videodev"];
    kernelModules = ["ledtrig-netdev"];
    tmp.useTmpfs = true;
  };

  boot.kernel.sysctl = {
    "vm.vfs_cache_pressure" = 10;
    "vm.dirty_ratio" = 50;
    "vm.swappiness" = 20;
  };

  powerManagement.cpuFreqGovernor = "schedutil";

  system.stateVersion = "23.11";
}
