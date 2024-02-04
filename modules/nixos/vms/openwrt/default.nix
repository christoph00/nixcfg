{
  inputs,
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.vms.openwrt;
  vmconfig = writeText "vmconfig.json" (builtins.toJSON {
    boot-source = {
      kernel_image_path = "/mnt/vm/openwrt/vmlinux";
      boot_args = "ro console=ttyS0 noapic reboot=k panic=1 pci=off nomodules random.trust_cpu=on i8042.noaux";
    };
    drives = [
      {
        drive_id = "rootfs";
        path_on_host = "/mnt/vm/openwrt/rootfs.img";
        is_root_device = false;
        is_read_only = true;
      }
    ];
    machine-config.vcpu_count = 2;
    machine-config.mem_size_mib = 512;
    network-interfaces = [
      {
        iface_id = "eth0";
        guest_mac = "02:fc:00:00:00:05";
        host_dev_name = "ow0eth0";
      }
      {
        iface_id = "eth1";
        guest_mac = "02:fc:00:00:00:06";
        host_dev_name = "ow0eth1";
      }
    ];
  });
in {
  options.chr.vms.openwrt = with types; {
    enable = mkBoolOpt' false;
  };

  config = mkIf cfg.enable {
    systemd.services.vm-openwrt = {
      enable = true;
      description = "VM: Openwrt";
      wantedBy = ["multi-user.target"];
      after = ["networking.service"];

      serviceConfig = {
        ExecStart = "${pkgs.firecracker}/bin/firecracker --no-api --config-file ${vmconfig}";
      };
    };
  };
}
