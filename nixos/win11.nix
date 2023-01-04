{
  config,
  pkgs,
  ...
}: let
  ovmf = "${pkgs.OVMF.fd}/FV";
  qemu_args = [
    "-name guest=win11"
    "-sandbox on,obsolete=deny,elevateprivileges=deny,spawn=deny,resourcecontrol=deny"
    "-machine pc-q35-7.0,pflash0=pflash0-blkdev,pflash1=pflash1-blkdev"
    "-accel kvm,kernel-irqchip=on"
    "-cpu host,hv_passthrough,kvm=off,-vmx"
    "-smp 6,cores=3,threads=2,sockets=1,maxcpus=6"
    "-m 16G"
    "-overcommit mem-lock=off"
    "-rtc base=localtime,driftfix=slew"
    "-global kvm-pit.lost_tick_policy=delay"
    "-no-hpet"
    "-nodefaults"
    "-monitor unix:/run/win11/qemu.sock,server,nowait"

    #"-blockdev node-name=os-storage,driver=host_device,filename=/dev/zvol/zm2/vm-100-disk-1,discard=unmap,aio=native,cache.direct=on"

    "-drive file=/dev/zvol/zdata/vm-100-disk-1,cache=none,if=virtio,format=raw"
    "-drive file=/dev/zvol/zdata/vm-100-disk-0,cache=none,if=virtio,format=raw"

    "-cdrom /zdata/virtio-win.iso"

    "-device pcie-root-port,bus=pcie.0,multifunction=on,port=1,chassis=1,id=rp0"
    "-device pcie-root-port,bus=pcie.0,multifunction=on,port=2,chassis=2,id=rp1"

    #"-netdev tap,fd=7,id=hostnet0"

    #  "-device vfio-pci,host=01:00.0,x-vga=on,multifunction=on,bus=rp0,addr=00.0,display=on,x-igd-opregion=on,ramfb=on,driver=vfio-pci-nohotplug"
    #  "-device vfio-pci,host=01:00.1"

    "-netdev tap,id=mynet0,ifname=tap0,script=no,downscript=no"
    "-device e1000,netdev=mynet0,mac=52:55:00:d1:55:01"

    "-device qemu-xhci,id=xhci0,multifunction=on,bus=rp0,addr=00.0"
    #"-device virtio-net,netdev=tap0,id=net0,bus=rp0,addr=00.1"
    #"-device virtio-blk-pci,drive=os-storage,bootindex=1,id=virtio-disk0,bus=rp0,addr=00.2"
    "-device ich9-usb-ehci1,id=usb0,multifunction=on,bus=rp0,addr=00.3"
    "-device virtio-balloon-pci,id=balloon0,bus=rp0,addr=00.4"

    "-device vfio-pci,multifunction=on,host=01:00.0,bus=rp1,addr=00.0"
    "-device vfio-pci,host=01:00.1,bus=rp1,addr=00.1"

    "-chardev socket,id=chrtpm,path=/tmp/emulated_tpm/swtpm-sock"
    "-tpmdev emulator,id=tpm0,chardev=chrtpm"
    "-device tpm-tis,tpmdev=tpm0"

    #"-device usb-host,bus=usb0.0,hostbus=3,hostport=1.1"
    "-device usb-host,bus=xhci0.0,vendorid=0x045e,productid=0x0800" # Microsoft Corp. Wireless keyboard (All-in-One-Media
    "-device usb-host,bus=xhci0.0,vendorid=0x046d,productid=0xc52b" # Logitech, Inc. Unifying Receiver
    "-device usb-host,bus=xhci0.0,vendorid=0x0bda,productid=0xa725" # Realtek Semiconductor Corp. (Bluetooth)

    "-device usb-host,bus=xhci0.0,vendorid=0x0000,productid=0x3825" #    USB OPTICAL MOUSE (Trust)
    "-device usb-host,bus=xhci0.0,vendorid=0x145f,productid=0x02c9" #    : Trust Trust Keyboard

    "-device usb-host,bus=xhci0.0,vendorid=0x18d1,productid=0x9400" #    : Stadia Controller

    #"-net nic,model=virtio,macaddr=e4:3a:46:7c:31:b6"
    #"-net bridge,br=br0"

    "-vga none -nographic"
  ];
  tap = "macvtap0";
  mac = "52:54:00:e2:d6:44";
  lan = "enp0s31f6";
  ip = "${pkgs.iproute}/bin/ip";
in {
  systemd.services.swtpm = {
    path = [pkgs.swtpm];
    script = ''
      mkdir -p /tmp/emulated_tpm
      swtpm socket \
        --tpmstate dir=/tmp/emulated_tpm \
        --ctrl type=unixio,path=/tmp/emulated_tpm/swtpm-sock \
        --log level=20 \
        --tpm2
    '';
    wantedBy = ["win11.service"];
  };

  systemd.services.win11 = {
    description = "Windows 11 VM";
    wantedBy = ["multi-user.target"];
    restartIfChanged = false;
    path = [pkgs.qemu pkgs.samba];
    conflicts = ["graphical.target" "display-manager.service"];
    script = ''
      ${pkgs.qemu_kvm}/bin/qemu-kvm \
        ${builtins.concatStringsSep " " qemu_args} \
        -blockdev node-name=pflash0-blkdev,driver=file,filename=${ovmf}/OVMF_CODE.fd,read-only=on \
        -blockdev node-name=pflash1-blkdev,driver=file,filename=${ovmf}/OVMF_VARS.fd,read-only=on
    '';

    #   -device virtio-net,netdev=hostnet0,id=net0,mac=${mac},bus=rp0,addr=00.1 \
    #    7<>/dev/tap$(< /sys/class/net/${tap}/ifindex)

    preStop = ''
      echo system_powerdown | ${pkgs.socat}/bin/socat - unix-connect:/run/win11/qemu.sock
      ${pkgs.coreutils}/bin/tail --pid=$MAINPID -f /dev/null
    '';

    #preStart = ''
    #   if ! test -e /sys/class/net/${tap}; then
    #     ${ip} l add name ${tap} link ${lan} type bridge
    #   fi
    #   ${ip} l set dev ${tap} addr ${mac}
    #   ${ip} l set ${tap} up
    # '';

    preStart = ''
       # Unbind VTconsoles: might not be needed
      #echo 0 > /sys/class/vtconsole/vtcon0/bind
      #echo 0 > /sys/class/vtconsole/vtcon1/bind

      # Unbind EFI Framebuffer
      #echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind

      ${pkgs.kmod}/sbin/modprobe -r amdgpu
      ${pkgs.kmod}/sbin/modprobe -r snd_hda_intel
      #${pkgs.kmod}/sbin/modprobe -r drm
      ${pkgs.kmod}/sbin/modprobe vendor-reset
      ${pkgs.kmod}/sbin/modprobe vfio_pci
      ${pkgs.kmod}/sbin/modprobe vfio
      ${pkgs.kmod}/sbin/modprobe vfio_iommu_type1
    '';

    postStop = ''
      ${pkgs.kmod}/sbin/modprobe -r vfio_pci
      ${pkgs.kmod}/sbin/modprobe -r vfio
      ${pkgs.kmod}/sbin/modprobe -r vfio_iommu_type1
      ${pkgs.kmod}/sbin/modprobe vendor-reset
      ${pkgs.kmod}/sbin/modprobe amdgpu
    '';

    serviceConfig = {
      RestartSec = 60;
      Restart = "on-failure";
      RuntimeDirectory = "win11";
      WorkingDirectory = "/run/win11";
    };

    after = ["swtpm.target"];
    bindsTo = ["swtpm.service"];

    # unitConfig = {
    # RequiresMountsFor = ["/var/lib/vms" "/var/lib/vms/ssd"];
    # };
  };
}
