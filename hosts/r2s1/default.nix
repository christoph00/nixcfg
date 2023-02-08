{
  config,
  lib,
  pkgs,
  ...
}: {
  hardware.deviceTree.name = "rockchip/rk3328-nanopi-r2s.dtb";
  # hardware.deviceTree.filter = "*rk3328-nanopi-r2s.dtb";
  # hardware.deviceTree.overlays = [{
  #   name = "sysled";
  #   dtsFile = ./files/sysled.dts;
  # }];

  hardware.deviceTree.package = pkgs.lib.mkForce (
    pkgs.runCommand "dtbs-nanopi-r2s" {} ''
      install -TDm644 ${./rk3328-nanopi-r2s.dtb} $out/rockchip/rk3328-nanopi-r2s.dtb
    ''
  );

  hardware.firmware = [
    (
      pkgs.runCommand
      "linux-firmware-r8152"
      {}
      "install -TDm644 ${./rtl8153a-4.fw} $out/lib/firmware/rtl_nic/rtl8153a-4.fw"
    )
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.loader = {
    systemd-boot.enable = lib.mkForce false;
    grub.enable = false;
    generic-extlinux-compatible = {
      enable = true;
      configurationLimit = 3;
    };
  };

  boot.kernelParams = [
    "console=ttyS2,1500000"
    "earlycon=uart8250,mmio32,0xff130000"
    "mitigations=off"
  ];
  boot.initrd = {
    includeDefaultModules = false;
    kernelModules = ["ledtrig-netdev"];
  };
  boot.blacklistedKernelModules = ["hantro_vpu" "drm" "lima" "videodev"];
  boot.kernelModules = ["ledtrig-netdev"];
  boot.tmpOnTmpfs = true;

  boot.kernel.sysctl = {
    "vm.vfs_cache_pressure" = 10;
    "vm.dirty_ratio" = 50;
    "vm.swappiness" = 20;
  };

  powerManagement.cpuFreqGovernor = "schedutil";

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = ["defaults" "size=512M" "mode=755"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "ext4";
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-label/NIX";
    fsType = "f2fs";
    options = ["compress_algorithm=zstd:6" "compress_chksum" "atgc" "gc_merge" "lazytime"];
  };

  swapDevices = [
    {
      device = "/nix/swapfile";
      size = 2048;
    }
  ];

  networking.hostName = "r2s1";

  # ----------  Secrets  -----------------------------------------
  #age.secrets.cloudflared.file = ../../secrets/oca-cf;
  age.secrets.tailscale-preauthkey.file = ../../secrets/tailscale-preauthkey;
  age.secrets.cf-acme.file = ../../secrets/cf-acme;
}
