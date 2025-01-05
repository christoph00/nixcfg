{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib,
  # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs,
  # You also have access to your flake's inputs.
  inputs,
  # Additional metadata is provided by Snowfall Lib.
  namespace,
  # The namespace used for your flake, defaulting to "internal" if not set.
  system,
  # The system architecture for this host (eg. `x86_64-linux`).
  target,
  # The Snowfall Lib target for this system (eg. `x86_64-iso`).
  format,
  # A normalized name for the system target (eg. `iso`).
  virtual,
  # A boolean to determine whether this system is a virtual target using nixos-generators.
  systems, # An attribute map of your defined hosts.

  # All other arguments come from the module system.
  config,
  ...
}:

with builtins;
with lib;
with lib.internal;

let
  cfg = config.internal.system.kernel;
in
{

  options.internal.system.kernel = with types; { };

  config = (
    mkMerge [
      {
        boot = {
          kernel.sysctl = {
            # The Magic SysRq key is a key combo that allows users connected to the
            # system console of a Linux kernel to perform some low-level commands.
            # Disable it, since we don't need it, and is a potential security concern.
            "kernel.sysrq" = 0;

            # Disable NMI watchdog
            "kernel.nmi_watchdog" = 0;

            # To hide any kernel messages from the console
            "kernel.printk" = "3 3 3 3";

            # Only swap when absolutely necessary
            "vm.swappiness" = "1";

            ## TCP hardening
            # Prevent bogus ICMP errors from filling up logs.
            "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
            # Reverse path filtering causes the kernel to do source validation of
            # packets received from all interfaces. This can mitigate IP spoofing.
            "net.ipv4.conf.default.rp_filter" = 1;
            "net.ipv4.conf.all.rp_filter" = 1;
            # Do not accept IP source route packets (we're not a router)
            "net.ipv4.conf.all.accept_source_route" = 0;
            "net.ipv6.conf.all.accept_source_route" = 0;
            # Don't send ICMP redirects (again, we're on a router)
            "net.ipv4.conf.all.send_redirects" = 0;
            "net.ipv4.conf.default.send_redirects" = 0;
            # Refuse ICMP redirects (MITM mitigations)
            "net.ipv4.conf.all.accept_redirects" = 0;
            "net.ipv4.conf.default.accept_redirects" = 0;
            "net.ipv4.conf.all.secure_redirects" = 0;
            "net.ipv4.conf.default.secure_redirects" = 0;
            "net.ipv6.conf.all.accept_redirects" = 0;
            "net.ipv6.conf.default.accept_redirects" = 0;
            # Protects against SYN flood attacks
            "net.ipv4.tcp_syncookies" = 1;
            # Incomplete protection again TIME-WAIT assassination
            "net.ipv4.tcp_rfc1337" = 1;

            ## TCP optimization
            # TCP Fast Open is a TCP extension that reduces network latency by packing
            # data in the sender’s initial TCP SYN. Setting 3 = enable TCP Fast Open for
            # both incoming and outgoing connections:
            "net.ipv4.tcp_fastopen" = 3;
            # Bufferbloat mitigations + slight improvement in throughput & latency
            "net.ipv4.tcp_congestion_control" = "bbr";

            "net.core.default_qdisc" = "cake";
            "net.core.wmem_max" = 1073741824;
            "net.core.rmem_max" = 1073741824;
            "net.ipv4.tcp_rmem" = "4096 87380 1073741824";
            "net.ipv4.tcp_wmem" = "4096 87380 1073741824";
          };
          kernelModules = [ "tcp_bbr" ];

          blacklistedKernelModules = [
            # Novideo
            "nvidia"
            "nvidia-drm"
            "nvidia-modeset"
            "nouveau"

            # Obscure network protocols
            "ax25"
            "netrom"
            "rose"

            # Old or rare or insufficiently audited filesystems
            "adfs"
            "affs"
            "bfs"
            "befs"
            "cramfs"
            "efs"
            "erofs"
            "exofs"
            "freevxfs"
            "f2fs"
            "vivid"
            "gfs2"
            "ksmbd"
            "nfsv4"
            "nfsv3"
            "cifs"
            "nfs"
            "cramfs"
            "freevxfs"
            "jffs2"
            "hfs"
            "hfsplus"
            "squashfs"
            "udf"
            "btusb"
            "hpfs"
            "jfs"
            "minix"
            "nilfs2"
            "omfs"
            "qnx4"
            "qnx6"
            "sysv"

          ];

          supportedFilesystems = lib.mkForce [
            "btrfs"
            "vfat"
            "f2fs"
            "xfs"
            "ext4"
            "vfat"
          ];
        };
      }
      (mkIf config.internal.isGraphical {
        #boot.kernelPackages = pkgs.linuxPackages_latest;
        boot.kernelPackages = pkgs.linuxPackages_cachyos;

        chaotic.scx.enable = true; # by default uses scx_rustland scheduler
        chaotic.scx.scheduler = "scx_bpfland";
        systemd.services.scx.serviceConfig.LogNamespace = "sched-ext";
        boot.kernelParams = [ "mitigations=off" ]; # disable mitigations on desktop

      })
      (mkIf config.internal.isHeadless {
        boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_cachyos-server;
      })
    ]
  );
}
