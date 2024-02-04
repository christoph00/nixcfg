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
in {
  options.chr.vms.openwrt = with types; {
    enable = mkBoolOpt' false;
  };

  config = mkIf cfg.enable {
    environment.etc."qemu/bridge.conf" = {
      user = "root";
      group = "qemu";
      mode = "640";
      text = "allow all";
    };

    security.wrappers.qemu-bridge-helper = {
      setuid = true;
      owner = "root";
      group = "root";
      source = "${pkgs.qemu_kvm}/libexec/qemu-bridge-helper";
    };

    systemd.network.networks."06-tap".extraConfig = ''
      [Match]
      Name = tap*

      [Link]
      Unmanaged = yes
    '';
    systemd.services.vm-openwrt = {
      enable = true;
      description = "VM: Openwrt";
      wantedBy = ["multi-user.target"];
      after = ["networking.service"];

      serviceConfig = {
        ExecStart = "${pkgs.qemu_kvm}/bin/qemu-system-x86_64 \
            -cpu host \
            -enable-kvm \
            -m 1G \
            -device virtio-serial \
            -drive file=/mnt/vm/openwrt/openwrt-ext4.img \
            -net nic,macaddr=${mac0},netdev=user.0,model=virtio \
            -netdev bridge,id=user.0,br=doctor-bridge \
            -net nic,macaddr=${mac1},netdev=user.1,model=virtio \
            -netdev bridge,id=user.1,br=doctor-bridge \
            -nographic";
      };
    };
  };
}
